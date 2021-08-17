(ns util
  (:require [clojure.data.json :as json]))

(defn ok
  ([ct body] (ok ct body {}))
  ([ct body headers]
   {:status 200
    :headers (merge (or headers {}) {"Content-Type" ct})
    :body body}))

(defn bad [status-code body]
  {:status status-code
   :headers {"Content-Type" "application/json"}
   :body (json/write-str body)})


