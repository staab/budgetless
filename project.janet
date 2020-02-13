(declare-project
  :name "budgetless"
  :description "A simple, budgetless personal finance app"
  :dependencies [
                 "https://github.com/joy-framework/halo.git"
                 "https://github.com/joy-framework/http.git"
                 "https://github.com/andrewchambers/janet-pq.git"
                 "https://github.com/janet-lang/json.git"])

(declare-executable
 :name "main"
 :entry "server/main.janet")
