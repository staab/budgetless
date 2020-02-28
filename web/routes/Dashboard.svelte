<script>
  import {onMount} from 'svelte'
  import Nav from 'partials/Nav'
  import Info from 'partials/Info'
  import SpentDonut from 'partials/SpentDonut'
  import EarnedDonut from 'partials/EarnedDonut'
  import {user} from 'util/state'
  import {fetchJson, dollars} from 'util/misc'
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

    console.log(data, $user)
  })
</script>

<Nav />
<div class="flex flex-col max-w-sm m-auto p-4">
  {#if loading}
  <div class="w-full flex justify-center">
    <h2 class="text-lg mt-12">Loading...</h2>
  </div>
  {:else}
  <div class="relative mb-8 h-32">
    <div class="absolute -mx-20 left-0">
      <SpentDonut {transactions} />
    </div>
    <div class="absolute -mx-20 right-0">
      <EarnedDonut {transactions} />
    </div>
  </div>
  <div class="flex text-2xl">
    <div class="w-2/3 whitespace-no-wrap">
      Account Balance <Info content="stuff" />
    </div>
    <div class="w-1/3 text-right">
      {dollars($user.balance)}
    </div>
  </div>
  {/if}
</div>
