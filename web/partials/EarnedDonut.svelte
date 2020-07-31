<script>
 import Chart from 'chart.js'
  import {onMount} from 'svelte'
  import {DateTime} from 'luxon'
  import {dollars, arc, equals} from 'util/misc'

  export let transactions = []
  let chart, width, height

  const back35 = DateTime.local().minus({days: 35})
  const back70 = DateTime.local().minus({days: 70})

  const nonTransferTransactions = transactions
    .filter(({categories}) => !equals(categories, ["Transfer", "Credit"]))

  const thisPeriod = nonTransferTransactions
    .filter(({transaction_date, amount}) =>
      amount < 0 && back35 < DateTime.fromISO(transaction_date)
    )
    .reduce((result, {amount}) => result - amount, 0)

  const lastPeriod = nonTransferTransactions
    .filter(({transaction_date, amount}) => {
      const dt = DateTime.fromISO(transaction_date)

      return amount < 0 && back35 > dt && back70 < dt
    })
    .reduce((result, {amount}) => result - amount, 0)

  const color = thisPeriod > lastPeriod ? '#81E6D9' : '#FC8181'
  const ratio = thisPeriod > lastPeriod
    ? Math.min(0.99999, (thisPeriod - lastPeriod) / lastPeriod)
    : thisPeriod / lastPeriod

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
    <path d="{arc(500, 500, 500, 0, ratio * 360)}" stroke="{color}" stroke-width="25" fill="transparent" />
  </svg>
</div>
<div class="absolute inset-0 flex flex-col justify-center align-center">
  <span class="title text-center text-3xl">{dollars(thisPeriod)}</span>
  <span class="subtitle text-center w-1/3 text-sm mx-auto">Earned in the last 35 days</span>
</div>
