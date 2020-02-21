(import util/pq)
(import util/misc)

# General purpose

(defn build-where [where &opt param-offset]
  (default param-offset 0)
  (def ks (keys where))
  (def $$ (map |(string "$" (+ 1 param-offset $)) (range (length ks))))
  (def k$ (map |(pq/composite (pq/ident $0) "=" $1) ks $$))
  [(map |(where $) ks) (pq/composite (string/join k$ " and "))])

(defn select [f tbl where]
  (def [vs where-str] (build-where where))
  (f (pq/composite "select * from" (pq/ident tbl) "where" where-str) ;vs))

(defn insert [tbl data]
  (def ks (keys data))
  (def vs (map |(data $) ks))
  (def $$ (map |(string "$" (inc $)) (range (length ks))))
  (pq/exec
    (pq/composite "insert into" (pq/ident tbl)
                  "(id, created," (string/join (map pq/ident ks) ",") ")"
                  "values (uuid_generate_v4(), now(), " (string/join $$ ",") ")")
    ;vs))

(defn update [tbl data where]
  (def ks (keys data))
  (def vs (map |(data $) ks))
  (def k$ (map (fn [[i k]] (string (pq/ident k) "=" (string "$" (inc i))))
               (misc/enumerate ks)))
  (def [where-vs where-sql] (build-where where (length ks)))
  (pq/exec
    (pq/composite "update" (pq/ident tbl) "set" (string/join k$ ",")
               "where" where-sql)
    ;vs
    ;where-vs))

(defn connect []
  (pq/connect (os/getenv "DATABASE_URL"))
  (map pq/exec (string/split ";" (slurp "server/schema.sql"))))

# Domain Specific

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
