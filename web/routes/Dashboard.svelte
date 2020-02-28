<script>
  import {onMount} from 'svelte'
  import Nav from 'partials/Nav'
  import SpentDonut from 'partials/SpentDonut'
  import EarnedDonut from 'partials/EarnedDonut'
  import {user} from 'util/state'
  import {fetchJson} from 'util/misc'
  import {navigate} from 'svelte-routing'

  let loading = true
  let transactions = []

  onMount(async () => {
    if (!$user.plaid_item_id) {
      navigate('/plaid/link')
    }

    const [_, {data}] = await fetchJson('GET', '/api/dashboard')

    loading = false
    transactions = data.transactions

    console.log(data)
  })
</script>

<Nav />
<div class="flex max-w-md m-auto p-4">
  {#if loading}
  <div class="w-full flex justify-center">
    <h2 class="text-lg mt-12">Loading...</h2>
  </div>
  {:else}
  <div class="flex space-between">
    <SpentDonut {transactions} />
    <EarnedDonut {transactions} />
  </div>
  {/if}
</div>
