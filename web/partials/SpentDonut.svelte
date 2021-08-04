<script>
  import Chart from 'chart.js'
  import {onMount} from 'svelte'
  import {DateTime} from 'luxon'
  import {dollars, arc, equals} from 'util/misc'

  export let transactions = []
  let chart, width, height

  const aWeekAgo = DateTime.local().minus({days: 7})
  const twoWeeksAgo = DateTime.local().minus({days: 14})

  const nonTransferTransactions = transactions
    .filter(({categories}) => !equals(categories, ["Transfer", "Debit"]))

  const thisWeek = nonTransferTransactions
    .filter(({transaction_date, amount, categories}) =>
      amount > 0 && aWeekAgo < DateTime.fromISO(transaction_date)
    )
    .reduce((result, {amount}) => result + amount, 0)

  const lastWeek = nonTransferTransactions
    .filter(({transaction_date, amount}) => {
      const dt = DateTime.fromISO(transaction_date)

      return amount > 0 && aWeekAgo > dt && twoWeeksAgo < dt
    })
    .reduce((result, {amount}) => result + amount, 0)

  const color = thisWeek > lastWeek ? '#FC8181' : '#81E6D9'
  const ratio = thisWeek > lastWeek
    //  ? Math.min(0.99999, (thisWeek - lastWeek) / lastWeek)
    ? lastWeek / thisWeek
    : thisWeek / lastWeek

  onMount(() => {
    const rect = chart.getBoundingClientRect()

    width = rect.width
    height = rect.height
  })
</script>

<style>
  .title {
    bottom: 50%;
  }

  .subtitle {
    bottom: 50%;
  }
</style>

<div bind:this={chart}>
  <svg {width} {height} xmlns="http://www.w3.org/2000/svg" viewBox="-100 -100 1200 1200">
    <path d="{arc(500, 500, 500, 0, 359.99)}" stroke="#EDF2F7" stroke-width="25" fill="transparent" />
    <path d="{arc(500, 500, 500, 0, (ratio || 0) * 360)}" stroke="{color}" stroke-width="25" fill="transparent" />
  </svg>
</div>
<div class="absolute inset-0 flex flex-col justify-center align-center">
  <span class="title text-center text-3xl">{dollars(thisWeek)}</span>
  <span class="subtitle text-center w-1/3 text-sm mx-auto">Spent in the last week</span>
</div>
