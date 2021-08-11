(ns server2.api
  (:require [clojure.data.json :as json]
            [clojure.string :as s]
            [server2.util :refer [ok bad]]
            [server2.db :as db]))

;; Utils

(defn ok-json
  ([body] (ok-json body {}))
  ([body headers]
   (ok "application/json" (json/write-str body) headers)))

(defn read-json [{:keys [body]}]
  (try (json/read-str (slurp body)) (catch Exception e nil)))

(def ADMIN_EMAIL "shtaab@gmail.com")

(defn send-email [to template data]
 (println [(str "Fake email to " to " using template " template) data]))

(defn get-cookie [req k]
  (if-let [cookie-str (get-in req [:headers "cookie"])]
    (get (apply hash-map (s/split cookie-str #"[=; ]+")) k)
    nil))

(defn get-email-from-req [req]
  (when-let [email (get (read-json req) "email")]
    (if (.contains email "@") email nil)))


;;  (defn sync-plaid [{:plaid_access_token token :id account-id}]
;;    (def start-date (db/get-sync-start-date account-id))
;;    (def limit 100)
;;    (var offset 0)
;;    (var done? (nil? token))
;;    (defn sync-transactions [offset]
;;      (let [payload {:access_token token
;;                     :start_date start-date
;;                     :end_date (db/date "now()")
;;                     :options {:count limit :offset offset}}
;;            res (plaid/post "/transactions/get" payload)]
;;        (when-let [e (res :error_message)] (error e))
;;        (each txn (filter |(not ($ :pending)) (res :transactions))
;;          (db/insert-or-update
;;            :transaction
;;            :plaid_transaction_id
;;            {:account (pq/uuid account-id)
;;             :transaction_date (pq/date (txn :date))
;;             :authorized_date (pq/date (txn :authorized_date))
;;             :name (txn :name)
;;             :transaction_type (txn :transaction_type)
;;             :payment_channel (txn :payment_channel)
;;             :amount (* 100 (txn :amount))
;;             :categories (pq/jsonb (txn :category))
;;             :plaid_transaction_id (txn :transaction_id)
;;             :plaid_account_id (txn :account_id)
;;             :plaid_category_id (txn :category_id)}))
;;        [(res :accounts) (res :total_transactions)]))
;;    (while (not done?)
;;      (let [[accounts total] (sync-transactions offset)]
;;        (set offset (+ limit offset))
;;        (set done? (<= total offset))
;;        (when done?
;;          (db/update
;;            :account
;;            {:balance (->> accounts
;;                           (map |(get-in $ [:balances :available]))
;;                           (filter identity)
;;                           (reduce + 0)
;;                           (* 100))}
;;            {:id (pq/uuid account-id)})))))

;; Routes

(defn whoami [req]
  (if-let [account (db/get-current-account (get-cookie req "session"))]
    (ok-json (select-keys account [:id :email :plaid_item_id :balance]))
    (bad 401 {:detail "No session found"})))

(defn dashboard [req]
  (if-let [account (db/get-current-account (get-cookie req "session"))]
    (do
      ;;  (sync-plaid account)
      (ok-json {:transactions (db/get-transactions (account :id))}))
    (bad 401 {:detail "No session found"})))

(defn link [req]
  (if-let [session (db/get-current-session (get-cookie req "session"))]
   (let [path "/item/public_token/exchange"
         {:keys [access_token item_id error_message]} {}] ;(plaid/post path (req :json))
    (when error_message (throw error_message))
    (db/link-account (:account session) access_token item_id)
    (ok-json {:plaid_item_id item_id}))
  (bad 401 {:detail "No session found"})))

(defn request-access [req]
  (if-let [email (get-email-from-req req)]
    (do
     (send-email ADMIN_EMAIL :request-access {:email email})
     (println (ok-json {}))
     (ok-json {}))
    (bad 400 {:detail "Please enter a valid email address."})))

(defn send-login-code [req]
  (if-let [{:keys [id email]} (db/get-account-by-email (get-email-from-req req))]
    (do
      (send-email email :login-code {:login-code (db/refresh-login-code id)})
      (ok-json {}))
    (bad 400 {:detail "No account was found for that email address."})))

(defn login-with-code [req]
  (let [{:keys [email code]} (read-json req)]
   (if-let [account (db/get-account-by-code email code)]
    (ok-json
      (select-keys account [:id :email :plaid_item_id :balance])
      {"Set-Cookie" (str "session=" (db/create-session (account :id)))})
    (bad 400 {:detail "Code is invalid, please try again."}))))

(defn logout [req]
  (db/delete-session (get-cookie req "session"))
  (ok-json {}))

(defn root [{:keys [request-method uri] :as req}]
  (case (str (name request-method) " " (s/replace uri #"/api/" ""))
    "get whoami" (whoami req)
    "get dashboard" (dashboard req)
    "post link" (link req)
    "post request-access" (request-access req)
    "post send-login-code" (send-login-code req)
    "post login-with-code" (login-with-code req)
    "post logout" (logout req)))

