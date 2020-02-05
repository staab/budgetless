(import halo)
(import json)
(import server/db)
(import server/ct)
(import server/plaid)

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
        res (json/decode (plaid/post path body))
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
      (if (string/find "text/html" (get-in req [:headers "Accept"] ""))
        (ok ct/html (slurp "index.html"))
        (or
         (case head
          "/api" (api/root req)
          "/public" {:file (string "." path)})
         (bad 404 {:detail "Not found"}))))))

(defn log-handler [h]
  (fn [req]
    (let [res (h req)]
      (pp (string (req :uri) " => " (res :status)))
      res)))

(defn main [& args]
  (db/connect)
  (let [port (eval-string (os/getenv "PORT"))]
    (halo/server (log-handler handler) port)))
