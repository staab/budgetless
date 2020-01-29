(import halo)
(import json)
(import server/db :as db)

(def ct/json "application/json")
(def ct/html "text/html")
(def ct/css "text/css")
(def ct/svg "image/svg+xml")
(def ct/png "image/png")
(def ct/js "application/javascript")

(defn infer-ct [path]
  (case (keyword (in (string/split "." path) 1))
    :json ct/json
    :html ct/html
    :css ct/css
    :svg ct/svg
    :png ct/png
    :js ct/js
    "application/octet-stream"))

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
   :body (json/encode body)})

(defn api/link [req]
  (let [path "/item/public_token/exchange"
        body (json/decode (req :body))
        res (json/decode (plaid "POST" path body))
        session-key (db/uuidgen)]
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
  (def [path qs] (string/split "?" (req :uri)))
  (if (string/find ".." path)
    (bad 404 (json/encode {:detail "Not found"}))
    (let [[head] (string/split "/" path 1)]
      (or
       (case head
        "/" (ok ct/html (slurp "index.html"))
        "/web" (ok (infer-ct path) (slurp (drop 1 path)))
        "/public" (ok (infer-ct path) (slurp (drop 1 path)))
        "/api" (api/root req))
       (bad 404 {:detail "Not found"})))))

(defn log-handler [h]
  (fn [req]
    (let [res (h req)]
      (pp (string (req :uri) " => " (res :status)))
      res)))

(defn main [& args]
  (db/connect)
  (let [port (eval-string (os/getenv "PORT"))]
    (halo/server (log-handler handler) port)))
