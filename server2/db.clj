(ns db
  (:require [clojure.java.jdbc :as jdbc]
            [clojure.string :as s]
            [clojure.data.json :as json])
  (:import [java.sql Timestamp]
           [org.postgresql.util PGobject]
           [org.postgresql.util PSQLException]
           [java.sql Date]
           [java.time LocalDate]
           [java.time Instant]))

;; https://github.com/remodoy/clj-postgresql
;; https://web.archive.org/web/20161024231548/http://hiim.tv/clojure/2014/05/15/clojure-postgres-json/
;; https://stackoverflow.com/questions/35071417/inserting-data-into-postgresql-json-columns-using-clojure-java-jdbc
;; https://andersmurphy.com/2019/08/03/clojure-using-java-time-with-jdbc.html

;; Adapters

(defn value-to-json-pgobject [value]
  (doto (PGobject.)
    (.setType "json")
      (.setValue (json/write-str value))))

(extend-protocol jdbc/ISQLValue
  java.time.Instant
  (sql-value [v]
    (Timestamp/from v))
  java.time.LocalDate
  (sql-value [v]
    (Date/valueOf v))
  clojure.lang.IPersistentMap
  (sql-value [value] (value-to-json-pgobject value))
  clojure.lang.IPersistentVector
  (sql-value [value] (value-to-json-pgobject value)))

(extend-protocol jdbc/IResultSetReadColumn
  PGobject
  (result-set-read-column [pgobj metadata idx]
    (let [type  (.getType pgobj)
          value (.getValue pgobj)]
      (case type
        "json" (json/read-str value :key-fn keyword)
        "jsonb" (json/read-str value :key-fn keyword)
        :else value))))

;; Database setup, domain specific stuff

(def url (System/getenv "JDBC_DATABASE_URL"))

(def db {:connection-uri url})

(defn now []
  (:d
   (first
    (jdbc/query db ["select to_char(now(), 'yyyy-mm-dd') as d"]))))

(defn get-account [id]
  (jdbc/get-by-id db :account id))

(defn get-account-by-email [email]
  (jdbc/get-by-id db :account email :email))

(defn refresh-login-code [id]
  (:login_code
   (first
    (jdbc/query db
     ["UPDATE account
       SET login_code =
         CASE
           WHEN login_code_expires > now() at time zone 'utc'
           THEN coalesce(login_code, floor(random() * 100000 + 100000)::text)
           ELSE floor(random() * 100000 + 100000)::text
         END,
         login_code_expires = now() at time zone 'utc' + INTERVAL '10 minute'
       WHERE id = ?
       RETURNING login_code"
       id]))))

(defn get-account-by-code [email login-code]
  (first
   (jdbc/query db
    ["select * from account where email = ? and login_code = ?" email login-code])))

(defn create-session [account-id]
  (:key
   (first
    (jdbc/query db
     ["insert into session (id, key, account)
       values (uuid_generate_v4(), uuid_generate_v4(), ?)
       returning key" account-id]))))

(defn get-current-session [session-key]
  (when session-key
    (jdbc/get-by-id db :session session-key :key)))

(defn get-current-account [session-key]
  (when-let [session (get-current-session session-key)]
    (jdbc/get-by-id db :account (:account session))))

(defn get-sync-start-date [account-id]
  (:start_date
   (first
    (jdbc/query db
      ["select to_char(
          coalesce(
            max(transaction_date::timestamp - interval '7' day),
            now() - interval '120' day
           ),
          'yyyy-mm-dd'
        ) as start_date
        from transaction where account = ?"
       account-id]))))

(defn get-transactions [account-id]
  (jdbc/query db ["select * from transaction where account = ? order by transaction_date asc" account-id]))

(defn link-account [id token item-id]
  (jdbc/update! db :account {:plaid_access_token token :plaid_item_id item-id} ["id = ?" id]))

(defn delete-session [session-key]
  (jdbc/delete! db :session ["key = ?" session-key]))

(defn save-transactions [account-id transactions]
  (let [cols [:account :transaction_date :authorized_date :name :transaction_type
            :payment_channel :amount :categories :plaid_transaction_id :plaid_account_id
            :plaid_category_id]
        ks [:account :date :authorized_date :name :transaction_type :payment_channel
            :amount :category :transaction_id :account_id :category_id]
        prep (fn [txn]
               (map (-> txn
                        (assoc :account account-id)
                        (update :date #(java.time.LocalDate/parse %)))
                    ks))
        columns (s/join ", " (map name cols))
        updates (s/join ", " (map #(str (name %) " = ?") cols))]
    (doall
     (for [txn transactions]
      (try
        (jdbc/query db
         (concat
          [(str
           "insert into transaction (id, " columns ")
            values (uuid_generate_v4(), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            on conflict (plaid_transaction_id) do update set " updates)]
          (prep txn)
          (prep txn)))
       ;; This always fails because it expects a result set
       (catch PSQLException e))))))

(defn update-balance [id balance]
  (jdbc/update! db :account {:balance balance} ["id = ?" id]))
