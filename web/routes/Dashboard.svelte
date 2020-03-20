<script>
  import {onMount} from 'svelte'
  import Nav from 'partials/Nav'
  import Info from 'partials/Info'
  import SpentDonut from 'partials/SpentDonut'
  import EarnedDonut from 'partials/EarnedDonut'
  import BalanceChart from 'partials/BalanceChart'
  import PurchaseDistribution from 'partials/PurchaseDistribution'
  import PurchaseBreakdown from 'partials/PurchaseBreakdown'
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
  <div class="flex">
    <div class="w-1/2 relative">
      <EarnedDonut {transactions} />
    </div>
    <div class="w-1/2 relative">
      <SpentDonut {transactions} />
    </div>
  </div>
  <div class="flex text-2xl mt-4">
    <div class="w-2/3 whitespace-no-wrap">
      Account Balance
      <Info content="The graph below shows your total available balance over
                     the last 30 days compared with the previous 30 days." />
    </div>
    <div class="w-1/3 text-right">
      {dollars($user.balance)}
    </div>
  </div>
  <div class="my-2">
    <BalanceChart {transactions} currentBalance={$user.balance} />
  </div>
  <div class="text-2xl w-2/3 whitespace-no-wrap mt-4">
    Purchase Distribution
    <Info content="Y-axis is average purchase amount. X-axis is the number
                   of purchases in the last 60 days. Bubble size represents the
                   relative amount spent on a given category." />
  </div>
  <div class="my-2">
    <PurchaseDistribution {transactions} />
  </div>
  <div class="text-2xl w-2/3 whitespace-no-wrap mt-4">
    Purchase Breakdown
    <Info content="Charts show 90 days of historical spend by category,
                   with weekly and monthly averages." />
  </div>
  <div class="my-2">
    <PurchaseBreakdown {transactions} />
  </div>
  {/if}
</div>
