(import halo)
(import json)

(defn curl [method url]
  (let [cmd (string/join ["curl -X" method url "--silent"] " ")]
    (with [f (file/popen cmd)]
      (file/read f :all))))

(def ct/json "application/json")
(def ct/html "text/html")
(def ct/css "text/css")
(def ct/svg "image/svg+xml")

(defn ok [ct body]
 {:status 200 :headers {"Content-Type" ct} :body body})

(defn bad [status-code body]
 {:status status-code :headers {"Content-Type" ct/json} :body body})

(defn api-handler [req]
  (ok ct/json (json/encode {:ok true})))

(defn handler [req]
  (if (string/find ".." (req :uri))
    (bad 404 (json/encode {:detail "Not found"}))
    (let [[head] (string/split "/" (req :uri) 1)]
      (case head
       "/" (ok ct/html (slurp "web/index.html"))
       "/web" (ok ct/css (slurp (drop 1 (req :uri))))
       "/public" (ok ct/html (slurp (drop 1 (req :uri))))
       "/api" (api-handler req)
       (bad 404 (json/encode {:detail "Not found"}))))))

(defn log-handler [h]
  (fn [req]
    (let [res (h req)]
      (pp (string (req :uri) "?" (req :query-string) " => " (res :status)))
      res)))

(defn main [& args]
  (let [port (eval-string (os/getenv "PORT"))]
    (halo/server (log-handler handler) port "0.0.0.0")))
