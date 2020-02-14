(import halo)
(import json)
(use server/util)
(import server/db)
(import server/ct)
(import server/plaid)

(def ADMIN_EMAIL "shtaab@gmail.com")

(defn tp [l x] (pp [l x]) x)

(defn send-email [to template data]
 (pp [(string "Fake email to " to " using template " template) data]))

(defn get-cookie [req k]
  (let [xs (->>
            (get-in req [:headers "Cookie"])
            (string/split "; ")
            (map |(string/split "=" $)))]
    ((table ;(flatten xs)) k)))

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

(defn api/link [req]
  (let [path "/item/public_token/exchange"
        res (json/decode (plaid/post path (req :json)))
        session-key (db/uuidgen)]
    (ok-json
     {:item_id (res "item_id")}
     {"Set-Cookie" (string "session=" session-key)})))

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
           account (db/get-account-by-code email code)]
    (ok-json (pick [:id :email] account))
    (bad 400 {:detail "No account was found for that email address."})))

(defn api/root [req]
  (let [k (string (req :method) " " (last (string/split "/" (req :uri) 1)))]
    (case k
      "POST link" (api/link req)
      "POST request-access" (api/request-access req)
      "POST send-login-code" (api/send-login-code req)
      "POST login-with-code" (api/login-with-code req)
      )))

(defn handler [req]
  (def [path qs] (string/split "?" (req :uri)))
  (if (string/find ".." path)
    (bad 404 (json/encode {:detail "Not found"}))
    (let [[head] (string/split "/" path 1)]
      (if (string/find "text/html" (get-in req [:headers "Accept"] ""))
        (ok ct/html (slurp "index.html"))
        (or
         (case head
          "/api" (api/root req)
          "/public" {:file (string "." path)})
         (bad 404 {:detail "Not found"}))))))

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
