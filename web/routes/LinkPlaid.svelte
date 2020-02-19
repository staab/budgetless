<script>
  import {Link, navigate} from "svelte-routing"
  import Door from 'partials/Door'

  const plaid = Plaid.create({
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

<Door>
  <h2 class="text-2xl my-2">Let's get started</h2>
  <p class="my-1">
    To avoid the tedious work of keeping your spending history up-to-date,
    we use <strong>Plaid</strong> to import it straight from your bank!
  </p>
  <div class="flex justify-center py-8">
    <button class="button button-primary" on:click={() => plaid.open()}>
      Connect with Plaid
    </button>
  </div>
</Door>
ode
