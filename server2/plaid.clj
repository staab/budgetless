(ns server2.plaid
  (:require [clojure.data.json :as json]
            [org.httpkit.client :as http]
            [server2.db :as db]))

(def auth
  {"client_id" (System/getenv "PLAID_CLIENT_ID")
   "secret" (System/getenv "PLAID_SECRET_KEY")})

(def url (str "https://" (System/getenv "PLAID_ENVIRONMENT") ".plaid.com"))

(defn request [method path data]
  (http/request
   {:method method
    :url (str url path)
    :body (json/write-str data)
    :headers {"Content-Type" "application/json"}}))

(defn exchange-token [data]
  (request "POST" "/item/public_token/exchange" data))

(defn sync-transactions [{:keys [token id]} start-date offset]
  (let [payload {:access_token token
                 :start_date start-date
                 :end_date (db/date "now()")
                 :options {:count 100 :offset offset}}
        {:keys [error_message transactions accounts total_transactions]}
        (request "POST" "/transactions/get" payload)]
    (when error_message (throw error_message))
    (db/save-transactions (remove :pending transactions))
    [accounts total_transactions]))

(defn sync-account [account]
  (let [start-date (db/get-sync-start-date (:id account))]
    (loop [offset 0 done? (empty? (:token account)) accounts []]
      (if done?
        (db/update-balance
         (:id account)
         (->> accounts
              (map #(get-in % [:balances :available]))
              (filter identity)
              (reduce + 0)
              (* 100)))
        (let [[accounts total] (sync-transactions account start-date offset)]
         (recur (+ offset 100) (<= total offset) accounts))))))

