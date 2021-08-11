(ns server2.db
  (:require [clojure.java.jdbc :as j]))

(def url (str (System/getenv "DATABASE_URL")
              "?ssl=true&sslfactory=org.postgresql.ssl.NonValidatingFactory"))

(def db {:connection-uri url})

(defn get-account [id]
  (j/get-by-id db :account id))

(defn get-account-by-email [email]
  (j/get-by-id db :account email :email))

(defn refresh-login-code [id]
  (:login_code
   (first
    (j/query db
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
   (j/query db
    ["select * from account where email = ? and login_code = ?" email login-code])))

(defn create-session [account-id]
  (:key
   (first
    (j/query db
     ["insert into session (key, account) values (uuid_generate_v4(), ?) returning key" account-id]))))

(defn get-current-session [session-key]
  (when session-key
    (j/get-by-id db :session session-key :key)))

(defn get-current-account [session-key]
  (when-let [session (get-current-session session-key)]
    (j/get-by-id db :account (:account session))))

(defn get-sync-start-date [account-id]
  (:start_date
   (first
    (j/query db
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
  (j/query db "select * from transaction where account = ?" account-id))

(defn link-account [id token item-id]
  (j/update! db :account {:plaid_access_token token :plaid_item_id item-id} ["id = ?" id]))

(defn delete-session [session-key]
  (j/delete! db :session ["key = ?" session-key]))

