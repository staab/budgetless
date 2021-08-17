(ns user
  (:require [clojure.tools.namespace.repl :refer [refresh]]
            [main :refer [start-server]]))

(def server nil)

(defn start []
  (alter-var-root #'server (constantly (start-server))))

(defn reload! []
  (when server (server :timeout 100))
  (refresh :after 'user/start))
