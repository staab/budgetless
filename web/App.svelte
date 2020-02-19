<script>
  import {Router, Route} from "svelte-routing"
  import Landing from 'routes/Landing'
  import Dashboard from 'routes/Dashboard'
  import Account from 'routes/Account'
  import LoginEmail from 'routes/LoginEmail'
  import LoginCode from 'routes/LoginCode'
  import LinkPlaid from 'routes/LinkPlaid'
  import Logout from 'routes/Logout'
  import Signup from 'routes/Signup'

  export let url = "";
</script>

<main>
  <Router {url}>
    <Route path="dashboard" component={Dashboard} />
    <Route path="account" component={Account} />
    <Route path="login/email" component={LoginEmail} />
    <Route path="login/code" component={LoginCode} />
    <Route path="plaid/link" component={LinkPlaid} />
    <Route path="logout" component={Logout} />
    <Route path="signup" component={Signup} />
    <Route path="*"><Landing /></Route>
  </Router>
</main>

























