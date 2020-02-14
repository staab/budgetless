(defn pick [ks x]
  (def r @{})
  (each k ks (put r k (x k)))
  r)
