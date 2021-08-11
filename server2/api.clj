(ns server2.api
  (:require [clojure.data.json :as json]
            [server2.util :refer [ok bad]]))

(defn ok-json [body & headers]
  (ok "application/json" (json/write-str body) headers))

(defn root [req]
  (ok "text/plain" "hi bob"))


