(ns main
  (:require [clojure.string :as s]
            [ring.adapter.jetty :refer [run-jetty]]
            [ring.middleware.file :refer [wrap-file file-request]]
            [ring.middleware.content-type :refer [wrap-content-type]]
            [ring.middleware.not-modified :refer [wrap-not-modified]]
            [ring.middleware.json :refer [wrap-json-body wrap-json-response]]
            [ring.util.response :refer [file-response]]
            [util :refer [ok bad]]
            [api :as api]))

(def client-routes
  (->> (s/split (slurp "web/App.svelte") #"\n")
       (filter #(.contains % "path="))
       (map #(nth (s/split % #"\"") 1))
       (map #(str "/" (if (= "*" %) "" %)))
       (set)))

(defn handle-errors [handler]
  (fn [request]
    (try
     (handler request)
     (catch Exception e
            (println e)
            (bad 500 {:detail "Internal Server Error"})))))

(defn app [request]
  (if (contains? client-routes (:uri request))
    (-> (file-response "index.html")
      (assoc-in [:headers "Content-Type"] "text/html"))
    (api/root request)))

(def wrapped
  (-> app
      (handle-errors)
      (wrap-json-body)
      (wrap-json-response)
      (wrap-file "public")
      (wrap-file "node_modules")
      (wrap-content-type)
      (wrap-not-modified)))

(defn start-server []
  (run-jetty wrapped {:port (Integer. (System/getenv "PORT")) :join? false}))

(defn -main [& args] (start-server))
