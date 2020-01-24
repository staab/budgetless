<script>
  import {Router, Route} from "svelte-routing"
  import Landing from 'routes/Landing'
  import Dashboard from 'routes/Dashboard'
  import Account from 'routes/Account'
  import Logout from 'routes/Logout'

  export let url = "";
</script>

<main>
  <Router {url}>
    <Route path="dashboard" component={Dashboard} />
    <Route path="account" component={Account} />
    <Route path="logout" component={Logout} />
    <Route path="*"><Landing /></Route>
  </Router>
</main>

























