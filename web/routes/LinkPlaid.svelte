<script>
  import {Link, navigate} from 'svelte-routing'
  import {fetchJson} from 'util/misc'
  import {user} from 'util/state'
  import Door from 'partials/Door'

  let loading = false

  const plaid = Plaid.create({
    clientName: 'Budgetless',
    countryCodes: ['US'],
    env: process.env.PLAID_ENVIRONMENT,
    key: process.env.PLAID_PUBLIC_KEY,
    product: ['transactions'],
    onSuccess: async public_token => {
      const [e, r] = await fetchJson('POST', '/api/link', {public_token})

      user.update(u => ({...u, ...r.data}))

      navigate('/dashboard')
    },
  })

  const link = () => {
    plaid.open()

    setTimeout(() => {
      loading = true
    }, 1000)
  }
</script>

<Door>
  {#if loading}
  <p class="text-center">Loading your dashboard...</p>
  {:else}
  <h2 class="text-2xl my-2">Let's get started</h2>
  <p class="my-1">
    To avoid the tedious work of keeping your spending history up-to-date,
    we use <strong>Plaid</strong> to import it straight from your bank!
  </p>
  <div class="flex justify-center py-8">
    <span class="text-right">
      <button class="button button-primary" on:click={link}>
        Connect with Plaid
      </button>
      <div class="pt-2">
        Or, <span class="underline"><Link to="/logout">Log Out</Link></span>
      </div>
    </span>
  </div>
  {/if}
</Door>
