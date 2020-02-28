<script>
  import Chart from 'chart.js'
  import {onMount} from 'svelte'
  import {DateTime} from 'luxon'
  import {dollars} from 'util/misc'

  export let transactions = []
  let canvas

  const back35 = DateTime.local().minus({days: 35})
  const back70 = DateTime.local().minus({days: 70})

  const thisPeriod = transactions
    .filter(({transaction_date, amount}) =>
      amount < 0 && back35 < DateTime.fromISO(transaction_date)
    )
    .reduce((result, {amount}) => result - amount, 0)

  const lastPeriod = transactions
    .filter(({transaction_date, amount}) => {
      const dt = DateTime.fromISO(transaction_date)

      return amount < 0 && back35 > dt && back70 < dt
    })
    .reduce((result, {amount}) => result - amount, 0)

  const color = thisPeriod > lastPeriod ? '#FC8181' : '#81E6D9'
  const data = thisPeriod > lastPeriod
    ? [thisPeriod, lastPeriod]
    : [lastPeriod, thisPeriod]

  onMount(() => {
    new Chart(canvas, {
      type: 'doughnut',
      data: {
        datasets: [{
          data,
          borderWidth: 0,
          backgroundColor: [color, '#EDF2F7'],
          hoverBackgroundColor: [color, '#EDF2F7'],
        }],
      },
      options: {
        tooltips: {
          enabled: false,
        },
        cutoutPercentage: 95,
      },
    })
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

<div class="relative -mx-10">
  <canvas bind:this={canvas} />
  <div class="absolute inset-0 flex flex-col justify-center align-center">
    <span class="title text-center text-3xl">{dollars(thisPeriod)}</span>
    <span class="subtitle text-center w-1/3 text-sm mx-auto">Earned in the last 35 days</span>
  </div>
</div>
