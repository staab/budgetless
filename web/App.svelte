<script>
  import {onMount} from 'svelte'
  import Chart from 'chart.js'
  import {Router, Route} from "svelte-routing"
  import Landing from 'routes/Landing'
  import Dashboard from 'routes/Dashboard'
  import Account from 'routes/Account'
  import LoginEmail from 'routes/LoginEmail'
  import LoginCode from 'routes/LoginCode'
  import LinkPlaid from 'routes/LinkPlaid'
  import Logout from 'routes/Logout'
  import Signup from 'routes/Signup'
  import {user} from 'util/state'
  import {fetchJson} from 'util/misc'

  export let url = "";
  let loading = true

  Chart.defaults.global.defaultFontColor = '#718096'

  onMount(async () => {
    const [e, r] = await fetchJson('GET', '/api/whoami',)

    if (!e) {
      user.set(r .data)
    }

    loading = false
  })
</script>

<main>
  <Router {url}>
    {#if $user}
    <Route path="dashboard" component={Dashboard} />
    <Route path="account" component={Account} />
    {/if}
    {#if !loading}
    <Route path="login/email" component={LoginEmail} />
    <Route path="login/code" component={LoginCode} />
    <Route path="plaid/link" component={LinkPlaid} />
    <Route path="logout" component={Logout} />
    <Route path="signup" component={Signup} />
    <Route path="*"><Landing /></Route>
    {/if}
  </Router>
</main>

























