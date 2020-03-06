(declare-project
  :name "budgetless"
  :description "A simple, budgetless personal finance app"
  :dependencies [
                 "https://github.com/joy-framework/halo.git"
                 {:repo "https://github.com/andrewchambers/janet-pq.git"
                  :tag "40537a09312dec7ce40e21974c2515a1236faf10"}
                 "https://github.com/janet-lang/json.git"
                 "https://github.com/staab/janet-util.git"])

(declare-executable
 :name "main"
 :entry "server/main.janet")
