(import util/pq)
(import util/misc)

# General purpose

(defn date [sql]
  (pq/val (pq/composite "select to_char(" sql ", 'yyyy-mm-dd')")))

(defn build-where [where &opt param-offset]
  (default param-offset 0)
  (def ks (keys where))
  (def $$ (map |(string "$" (+ 1 param-offset $)) (range (length ks))))
  (def k$ (map |(pq/composite (pq/ident $0) "=" $1) ks $$))
  [(map |(where $) ks) (pq/composite (string/join k$ " and "))])

(defn select [f tbl where]
  (def [vs where-str] (build-where where))
  (f (pq/composite "select * from" (pq/ident tbl) "where" where-str) ;vs))

(defn delete [f tbl where]
  (def [vs where-str] (build-where where))
  (f (pq/composite "delete from" (pq/ident tbl) "where" where-str) ;vs))

(defn build-insert [tbl data offset]
  (def ks (keys data))
  (def vs (map |(data $) ks))
  (def $$ (map |(string "$" (inc (+ offset $))) (range (length ks))))
  [vs
   (pq/composite
     "(id, created," (string/join (map pq/ident ks) ",") ")"
     "values (uuid_generate_v4(), now(), " (string/join $$ ",") ")")])

(defn insert [tbl data]
  (def [vs cmd] (build-insert tbl data 0))
  (pq/exec (pq/composite "insert into" (pq/ident tbl) cmd) ;vs))

(defn build-update [tbl data offset]
  (def ks (keys data))
  (def vs (map |(data $) ks))
  (def k$ (map (fn [[i k]]
                 (string (pq/ident k) "=" (string "$" (inc (+ offset i)))))
               (misc/enumerate ks)))
  [vs (pq/composite "set" (string/join k$ ","))])

(defn update [tbl data where]
  (def [vs cmd] (build-update tbl data 0))
  (def [where-vs where-sql] (build-where where (length vs)))
  (pq/exec
    (pq/composite "update" (pq/ident tbl) cmd  "where" where-sql)
    ;vs ;where-vs))

(defn insert-or-update [tbl unique-field data]
  (pp [1 tbl])
  (def [insert-vs insert-cmd] (build-insert tbl data 0))
  (def [update-vs update-cmd] (build-update tbl data (length insert-vs)))
  (pq/exec
    (misc/tp "x" (pq/composite "insert into" (pq/ident tbl) insert-cmd
                  "on conflict (" (pq/ident unique-field) ") do update"
                  update-cmd))
    ;insert-vs
    ;update-vs))


(defn connect []
  (pq/connect (os/getenv "DATABASE_URL"))
  (map pq/exec (string/split ";" (slurp "server/schema.sql"))))

# Domain Specific

(defn get-account [id]
  (select pq/row :account {:id (pq/uuid id)}))

(defn get-account-by-email [email]
  (select pq/row :account {:email email}))

(defn refresh-login-code [id]
  (pq/refresh-login-code :account :login_code :login_code_expires id))

(defn get-account-by-code [email login-code]
  (select pq/row :account {:email email :login_code login-code}))

(defn create-session [account-id]
  (let [session-key (pq/id)]
    (insert :session {:key (pq/uuid session-key)
                      :account (pq/uuid account-id)})
    session-key))

(defn get-sync-start-date [account-id]
  (pq/val
    `select to_char(
       coalesce(max(transaction_date::timestamp), now()) - interval '7' day,
       'yyyy-mm-dd'
     )
     from transaction where account = $1`
    (pq/uuid account-id)))

(defn get-transactions [account-id]
  (select pq/all :transaction {:account (pq/uuid account-id)}))
