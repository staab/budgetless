(import pqutils :as pq)

(put pq/*decoders* 2950 string)

(defn connect []  (pq/connect (os/getenv "DATABASE_URL")))

(defn uuidgen [] (pq/val "select uuid_generate_v4()"))
