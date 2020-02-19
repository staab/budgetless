(defn pick [ks x]
  (def r @{})
  (each k ks (put r k (x k)))
  r)

(defn enumerate [xs]
  (def r @[])
  (loop [i :range [0 (length xs)]]
    (array/push r [i (in xs i)]))
  r)
