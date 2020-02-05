(def json "application/json")
(def html "text/html")
(def css "text/css")
(def svg "image/svg+xml")
(def png "image/png")
(def js "application/javascript")

(defn infer [path]
  (case (keyword (in (string/split "." path) 1))
    :json json
    :html html
    :css css
    :svg svg
    :png png
    :js js
    "application/octet-stream"))
