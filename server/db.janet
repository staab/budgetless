(import pq)

(put pq/*decoders* 2950 string)

(var conn nil)

(defn ident [x] (pq/escape-identifier conn (string x)))
(defn liter [x] (pq/escape-literal conn (string x)))
(defn composite [& args] (string/join args " "))
(defn exec [& args] (pq/exec conn ;args))
(defn all [& args] (pq/all conn ;args))
(defn row [& args] (pq/row conn ;args))
(defn col [& args] (pq/col conn ;args))
(defn val [& args] (pq/val conn ;args))

(defn uuidgen [] (val "select uuid_generate_v4()"))

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
