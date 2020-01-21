<script>
  import {Router, Link, Route} from "svelte-routing"
  import Landing from 'routes/Landing'
  import Dashboard from 'routes/Dashboard'
  import Account from 'routes/Account'
  import Logout from 'routes/Logout'

  export let url = "";

  const handler = Plaid.create({
    clientName: 'Budgetless',
    countryCodes: ['US'],
    env: 'sandbox',
    key: process.env.PLAID_PUBLIC_KEY,
    product: ['transactions'],
    onSuccess: public_token =>
      fetch('/api/link', {
        method: 'POST',
        body: JSON.stringify({public_token}),
      }),
  })
</script>

<main>
  <Router {url}>
    <nav>
      <Link to="/dashboard">Dashboard</Link>
      <Link to="/account">Account</Link>
      <Link to="/logout">Log Out</Link>
    </nav>
    <div>
      <Route path="dashboard" component={Dashboard} />
      <Route path="account" component={Account} />
      <Route path="logout" component={Logout} />
      <Route path="/"><Landing /></Route>
    </div>
  </Router>
	<button on:click={() => handler.open()}>Link</button>
</main>

























