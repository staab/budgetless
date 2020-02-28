<script>
  import Chart from 'chart.js'
  import {onMount} from 'svelte'
  import {DateTime} from 'luxon'
  import {dollars} from 'util/misc'

  export let transactions = []
  let canvas

  const aWeekAgo = DateTime.local().minus({days: 7})
  const twoWeeksAgo = DateTime.local().minus({days: 14})

  const thisWeek = transactions
    .filter(({transaction_date, amount}) =>
      amount > 0 && aWeekAgo < DateTime.fromISO(transaction_date)
    )
    .reduce((result, {amount}) => result + amount, 0)

  const lastWeek = transactions
    .filter(({transaction_date, amount}) => {
      const dt = DateTime.fromISO(transaction_date)

      return amount > 0 && aWeekAgo > dt && twoWeeksAgo < dt
    })
    .reduce((result, {amount}) => result + amount, 0)

  const color = thisWeek > lastWeek ? '#FC8181' : '#81E6D9'
  const data = thisWeek > lastWeek ? [thisWeek, lastWeek] : [lastWeek, thisWeek]

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

<canvas bind:this={canvas} />
<div class="absolute inset-0 flex flex-col justify-center align-center">
  <span class="title text-center text-3xl">{dollars(thisWeek)}</span>
  <span class="subtitle text-center w-1/3 text-sm mx-auto">Spent in the last week</span>
</div>
