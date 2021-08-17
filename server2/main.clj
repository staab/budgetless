(ns server2.main
  (:require [clojure.string :as s]
            [org.httpkit.server :refer [run-server]]
            [server2.util :refer [ok bad]]
            [server2.api :as api]))

(def client-routes
  (->> (s/split (slurp "web/App.svelte") #"\n")
       (filter #(.contains % "path="))
       (map #(nth (s/split % #"\"") 1))
       (map #(hash-map (str "/" (if (= "*" %) "" %))
                       (ok "text/html" (slurp "index.html"))))
       (apply merge)))

(defn handle-errors [route req]
  (try
   (route req)
   (catch Exception e
          (println e)
          (bad 500 {:detail "Internal Server Error"}))))

(defn send-file [uri]
  (let [ct (case (last (s/split uri #"\."))
                 "svg" "image/svg+xml"
                 "png" "image/png"
                 "jpg" "image/jpg"
                 "css" "text/css"
                 "ico" "image/x-icon"
                 "js" "test/javascript"
                 "text/plain")]
    (println uri ct)
    (ok ct (slurp (str "." uri)))))

(defn app [{:keys [uri query-string] :as req}]
  (if (.contains uri "..")
    (bad 404 {:detail "Not found"})
    (let [[head] (remove empty? (s/split uri #"/"))]
      (or
       (get client-routes uri)
       (case head
        "api" (handle-errors api/root req)
        "public" (send-file uri)
        "node_modules" (send-file uri)
        :else (bad 404 {:detail "Not found"}))))))

(defn start-server []
  (run-server app {:port (Integer. (System/getenv "PORT"))}))

(defn -main [& args] (start-server))
