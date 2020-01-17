(import pqutils :as sql)

(put sql/*decoders* 2950 string)

(defn connect []  (sql/connect (os/getenv "DATABASE_URL")))

(defn uuidgen [] (sql/scalar "select uuid_generate_v4()"))
