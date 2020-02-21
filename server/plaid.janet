(import json)
(import util/ct)

(def- auth
  {"client_id" (os/getenv "PLAID_CLIENT_ID")
   "secret" (os/getenv "PLAID_SECRET_KEY")})

(defn prep-headers [headers]
  (buffer ;(map (fn [[k v]] (string " -H '" k ": " v "'")) (pairs headers))))

(defn prep-body [data]
  (if data (buffer " -d '" (json/encode (merge data auth)) "'") ""))

(defn build-cmd [url headers body]
  (string "curl " url (prep-headers headers) (prep-body body)))

(defn request [method path data]
  (let [url (string "https://sandbox.plaid.com" path)
        headers {"Content-Type" ct/json}]
    (with [f (file/popen (build-cmd url headers data))]
      (json/decode (file/read f :all) true true))))

(def get (partial request "GET"))
(def post (partial request "POST"))
