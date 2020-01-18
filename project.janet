(declare-project
  :name "budgetless"
  :description "A simple, budgetless personal finance app"
  :dependencies [
                 # "https://github.com/joy-framework/halo.git"
                 "https://github.com/staab/halo.git"
                 "https://github.com/staab/janet-pgutils.git"
                 "https://github.com/janet-lang/json.git"])

(declare-executable
 :name "main"
 :entry "server/main.janet")
