<script>
  import {Router, Route} from "svelte-routing"
  import Landing from 'routes/Landing'
  import Dashboard from 'routes/Dashboard'
  import Account from 'routes/Account'
  import Login from 'routes/Login'
  import Logout from 'routes/Logout'
  import Signup from 'routes/Signup'

  export let url = "";
</script>

<main>
  <Router {url}>
    <Route path="dashboard" component={Dashboard} />
    <Route path="account" component={Account} />
    <Route path="login" component={Login} />
    <Route path="logout" component={Logout} />
    <Route path="signup" component={Signup} />
    <Route path="*"><Landing /></Route>
  </Router>
</main>

























