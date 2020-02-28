(import halo)
(import json)
(import util/pq)
(import util/ct)
(import util/misc)
(import server/db)
(import server/plaid)

(def ADMIN_EMAIL "shtaab@gmail.com")

(defn send-email [to template data]
 (pp [(string "Fake email to " to " using template " template) data]))

(defn get-cookie [req k]
  (let [xs (->>
            (get-in req [:headers "Cookie"])
            (string/split "; ")
            (map |(string/split "=" $)))]
    ((table ;(flatten xs)) k)))

(defn get-current-session [req]
  (if-let [session-key (get-cookie req "session")]
    (db/select pq/row :session {:key session-key})))

(defn get-current-account [req]
  (if-let [session (get-current-session req)]
    (db/select pq/row :account {:id (pq/uuid (session :account))})))

(defn ok [ct body &opt headers]
  {:status 200
   :headers (merge (or headers {}) {"Content-Type" ct})
   :body body})

(defn ok-json [body &opt headers]
  (ok ct/json (json/encode body) headers))

(defn bad [status-code body]
  {:status status-code
   :headers {"Content-Type" ct/json}
   :body (json/encode body)})

(defn get-email-from-req [req]
  (let [email (get-in req [:json :email])]
    (if (string/find "@" email) email nil)))

(defn api/whoami [req]
  (if-let [account (get-current-account req)]
    (ok-json (misc/pick [:id :email :plaid_item_id :balance] account))
    (bad 401 {:detail "No session found"})))

(defn sync-plaid [{:plaid_access_token token :id account-id}]
  (def start-date (db/get-sync-start-date account-id))
  (def limit 10)
  (var offset 0)
  (var done? false)
  (defn sync-transactions [offset]
    (let [payload {:access_token token
                   :start_date start-date
                   :end_date (db/date "now()")
                   :options {:count limit :offset offset}}
          res (plaid/post "/transactions/get" payload)]
      (when-let [e (res :error_message)] (error e))
      (each txn (res :transactions)
        (db/insert-or-update
          :transaction
          :plaid_transaction_id
          {:account (pq/uuid account-id)
           :transaction_date (pq/date (txn :date))
           :authorized_date (pq/date (txn :authorized_date))
           :name (txn :name)
           :transaction_type (txn :transaction_type)
           :payment_channel (txn :payment_channel)
           :amount (* 100 (txn :amount))
           :pending (txn :pending)
           :categories (pq/jsonb (txn :category))
           :plaid_transaction_id (txn :transaction_id)
           :plaid_account_id (txn :account_id)
           :plaid_category_id (txn :category_id)}))
      [(res :accounts) (res :total_transactions)]))
  (while (not done?)
    (let [[accounts total] (sync-transactions offset)]
      (set offset (+ limit offset))
      (set done? (<= total offset))
      (when done?
        (db/update
          :account
          {:balance (->> accounts
                         (map |(get-in $ [:balances :available]))
                         (filter identity)
                         (reduce + 0)
                         (* 100))}
          {:id (pq/uuid account-id)})))))


(defn api/dashboard [req]
  (if-let [account (get-current-account req)]
    (ok-json {:transactions (db/get-transactions (account :id))})
    (bad 401 {:detail "No session found"})))

(defn api/link [req]
  (if-let [session (get-current-session req)
           path "/item/public_token/exchange"
           {:access_token token :item_id item-id} (plaid/post path (req :json))]
    (do
      (db/update
        :account
        {:plaid_access_token token :plaid_item_id item-id}
        {:id (pq/uuid (session :account))})
      (ok-json {:plaid_item_id item-id}))
    (bad 401 {:detail "No session found"})))

(defn api/log-error [req]
  (send-email ADMIN_EMAIL :error req))

(defn api/request-access [req]
  (if-let [email (get-email-from-req req)]
    (do
      (send-email ADMIN_EMAIL :request-access {:email email})
      (ok-json {}))
    (bad 400 {:detail "Please enter a valid email address."})))

(defn api/send-login-code [req]
  (if-let [email (get-email-from-req req)
           account (db/get-account-by-email email)
           login-code (db/refresh-login-code (account :id))]
    (do
      (send-email email :login-code {:login-code login-code})
      (ok-json {}))
    (bad 400 {:detail "No account was found for that email address."})))

(defn api/login-with-code [req]
  (if-let [email (get-in req [:json :email])
           code (get-in req [:json :login_code])
           account (db/get-account-by-code email code)
           session-key (db/create-session (account :id))]
    (do
      (sync-plaid account)
      (ok-json
        (misc/pick
          [:id :email :plaid_item_id :balance]
          (db/get-account (account :id)))
        {"Set-Cookie" (string "session=" session-key)}))
    (bad 400 {:detail "No account was found for that email address."})))

(defn api/logout [req]
  (when-let [session-key (get-cookie req "session")]
    (db/delete pq/exec :session {:key session-key}))
  (ok-json {}))

(defn api/root [req]
  (let [k (string (req :method) " " (last (string/split "/" (req :uri) 1)))]
    (case k
      "GET whoami" (api/whoami req)
      "GET dashboard" (api/dashboard req)
      "POST link" (api/link req)
      "POST request-access" (api/request-access req)
      "POST send-login-code" (api/send-login-code req)
      "POST login-with-code" (api/login-with-code req)
      "POST logout" (api/logout req)
      )))

(def client-routes
  (->> (slurp "web/App.svelte")
       (string/split "\n")
       (filter |(string/find "path=" $))
       (map |(in (string/split "\"" $) 1))
       (map |(tuple (string "/" (if (= "*" $) "" $)) {:file "index.html"}))
       (flatten)
       (apply struct)))

(defn handler [req]
  (def [path qs] (string/split "?" (req :uri)))
  (if (string/find ".." path)
    (bad 404 (json/encode {:detail "Not found"}))
    (let [[head] (string/split "/" path 1)]
      (or
       (get client-routes path)
       (case head
        "/api" (api/root req)
        "/public" {:file (string "." path)}
        "/node_modules" {:file (string "." path)})
       (bad 404 {:detail "Not found"})))))

(defn log-handler [h]
  (fn [req]
    (when (= ct/json (get-in req [:headers "Content-Type"]))
      (put req :json (json/decode (req :body) true true)))
    (let [res (h req)]
      (pp (string (req :uri) " => " (res :status)))
      res)))

(defn main [& args]
  (db/connect)
  (let [port (eval-string (os/getenv "PORT"))]
    (halo/server (log-handler handler) port)))
