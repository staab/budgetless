(ns server2.api
  (:require [clojure.data.json :as json]
            [clojure.string :as s]
            [server2.util :refer [ok bad]]
            [server2.plaid :as plaid]
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
  (when-let [cookie-str (get-in req [:headers "cookie"])]
    (last (re-find (re-pattern (str k "=([^;]+);")) cookie-str))))

(defn get-email-from-req [req]
  (when-let [email (get (read-json req) "email")]
    (if (.contains email "@") email nil)))

;; Routes

(defn whoami [req]
  (if-let [account (db/get-current-account (get-cookie req "session"))]
    (ok-json (select-keys account [:id :email :plaid_item_id :balance]))
    (bad 401 {:detail "No session found"})))

(defn dashboard [req]
  (if-let [account (db/get-current-account (get-cookie req "session"))]
    (do
      (plaid/sync-account account)
      (ok-json {:transactions (db/get-transactions (account :id))}))
    (bad 401 {:detail "No session found"})))

(defn link [req]
  (if-let [session (db/get-current-session (get-cookie req "session"))]
   (let [{:keys [access_token item_id error_message]} (plaid/exchange-token (req :json))]
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

