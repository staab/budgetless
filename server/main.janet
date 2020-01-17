(import pq)
(import halo)
(import json)

(def conn (pq/connect (os/getenv "DATABASE_URL")))
(put pq/*decoders* 2950 string)
(defn uuidgen [] (pq/exec conn "select uuid_generate_v4()"))

(def ct/json "application/json")
(def ct/html "text/html")
(def ct/css "text/css")
(def ct/svg "image/svg+xml")

(defn curl/stringify-headers [xs]
  (string/join (map (fn [[k v]] (string "-H '" k ":" v "'")) (pairs (or xs []))) " "))

(defn curl [method url &opt headers body]
  (let [headers (curl/stringify-headers headers)
        body (if body (string/join ["-d'" body "'"] " ") "")
        cmd ["curl -X" method url headers body "--silent"]]
    (with [f (file/popen (string/join cmd " "))]
      (file/read f :all))))

(def plaid-auth
  {"client_id" (os/getenv "PLAID_CLIENT_ID")
   "secret" (os/getenv "PLAID_SECRET_KEY")})

(defn plaid [method path body]
  (let [url (string "https://sandbox.plaid.com" path)
        body (json/encode (merge body plaid-auth))]
    (curl method url {"Content-Type" ct/json} body)))

(defn get-cookie [req k]
  (let [xs (->>
            (get-in req [:headers "Cookie"])
            (string/split "; ")
            (map |(string/split "=" $)))]
    ((table ;(flatten xs)) k)))

(defn ok [ct body &opt headers]
  {:status 200
   :headers (merge (or headers {}) {"Content-Type" ct})
   :body body})

(defn bad [status-code body]
  {:status status-code
   :headers {"Content-Type" ct/json}
   :body body})

(defn api/link [req]
  (let [path "/item/public_token/exchange"
        body (json/decode (req :body))
        res (json/decode (plaid "POST" path body))
        session-key (uuidgen)]
    (ok
     ct/json
     (json/encode {:item_id (res "item_id")})
     {"Set-Cookie" (string "session=" session-key)})))

(defn api/root [req]
  (let [k (string (req :method) " " (last (string/split "/" (req :uri) 1)))]
    (if (= k "POST link")
      (api/link req)
      (case k
            ))))

(defn handler [req]
  (if (string/find ".." (req :uri))
    (bad 404 (json/encode {:detail "Not found"}))
    (let [[head] (string/split "/" (req :uri) 1)]
      (or
       (case head
        "/" (ok ct/html (slurp "web/index.html"))
        "/web" (ok ct/css (slurp (drop 1 (req :uri))))
        "/public" (ok ct/html (slurp (drop 1 (req :uri))))
        "/api" (api/root req))
       (bad 404 (json/encode {:detail "Not found"}))))))

(defn log-handler [h]
  (fn [req]
    (let [res (h req)]
      (pp (string (req :uri) "?" (req :query-string) " => " (res :status)))
      res)))

(defn main [& args]
  (let [port (eval-string (os/getenv "PORT"))]
    (halo/server (log-handler handler) port)))
