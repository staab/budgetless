(import http)
(import json)
(import server/ct)

(def- auth
  {"client_id" (os/getenv "PLAID_CLIENT_ID")
   "secret" (os/getenv "PLAID_SECRET_KEY")})

(defn request [method path body]
  (method
   (string "https://sandbox.plaid.com" path)
   :headers {"Content-Type" ct/json}
   :body (json/encode (merge body auth))))

(def get (partial request http/get))
(def post (partial request http/post))
