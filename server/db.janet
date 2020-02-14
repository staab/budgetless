(import pq)

(put pq/*decoders* 2950 string)
(put pq/*decoders* 1114 string)

(var conn nil)

(defn uuid [x] [2950 false x])
(defn ident [x] (pq/escape-identifier conn (string x)))
(defn liter [x] (pq/escape-literal conn (string x)))
(defn composite [& args] (string/join args " "))
(defn exec [& args] (pq/exec conn ;args))
(defn all [& args] (pq/all conn ;args))
(defn row [& args] (pq/row conn ;args))
(defn col [& args] (pq/col conn ;args))
(defn val [& args] (pq/val conn ;args))

# Special purpose

(defn uuidgen [] (val "select uuid_generate_v4()"))

(defn select [f tbl where]
  (def ks (keys where))
  (def vs (map |(where $) ks))
  (def $$ (map |(string "$" (inc $)) (range (length ks))))
  (def k$ (map |(composite (ident $0) "=" $1) ks $$))
  (f (composite "select * from" (ident tbl)
                "where" (composite (string/join k$ " and ")))
     ;vs))

(defn insert [tbl data]
  (def ks (keys data))
  (def vs (map |(data $) ks))
  (def $$ (map |(string "$" (inc $)) (range (length ks))))
  (exec
    (composite "insert into" (ident tbl)
               "(id, created," ;(map ident ks) ")"
               "values (uuid_generate_v4(), now(), " ;$$ ")")
    ;vs))

(defn connect []
  (set conn (pq/connect (os/getenv "DATABASE_URL")))
  (pq/exec conn (string (slurp "server/schema.sql"))))

# Domain Specific

(defn get-account-by-email [email]
  (select row :account {:email email}))

(defn refresh-login-code [id]
  (pp id)
  (val
    `UPDATE account
     SET login_code = CASE
           WHEN login_code_expires > now() at time zone 'utc'
           THEN coalesce(login_code, floor(random() * 100000 + 100000)::text)
           ELSE floor(random() * 100000 + 100000)::text
         END,
         login_code_expires = now() at time zone 'utc' + INTERVAL '10 minute'
     WHERE id = $1
     RETURNING login_code`
     (uuid id)))

(defn get-account-by-code [email login-code]
  (select row :account {:email email :login_code login-code}))
