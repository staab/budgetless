<script>
  import Chart from 'chart.js'
  import {onMount} from 'svelte'
  import {DateTime} from 'luxon'
  import {dollars, colors, rgba, scaleBetween, add, dollarsk, last} from 'util/misc'

  export let transactions
  let canvas

  const back60 = DateTime.local().minus({days: 60})

  const transactionsInPeriod = transactions
    .filter(({transaction_date, amount}) =>
      amount > 0 && back60 < DateTime.fromISO(transaction_date)
    )

  const categories = transactionsInPeriod
    .map(({categories}) => last(categories))
    .filter((x, idx, self) => self.indexOf(x) === idx)

  const transactionsByCategory = transactionsInPeriod
    .reduce(
      (r, {categories, amount}) => {
        const s = last(categories)
        const v = r[s] || []

        return {...r, [s]: v.concat(amount)}
      },
      {}
    )

  const totalInPeriod = transactionsInPeriod
    .reduce((r, {amount}) => r + amount, 0)

  const min = Object.values(transactionsByCategory)
    .reduce((r, amounts) => Math.min(r, amounts.reduce(add, 0)), Infinity)

  const max = Object.values(transactionsByCategory)
    .reduce((r, amounts) => Math.max(r, amounts.reduce(add, 0)), 0)

  const colorValues = Object.values(colors)

  const datasets = categories
    .sort((a, b) => (
      transactionsByCategory[b].reduce(add, 0)
      - transactionsByCategory[a].reduce(add, 0)
    ))
    .slice(0, colorValues.length - 1)
    .map((label, idx) => {
      const amounts = transactionsByCategory[label]
      const total = amounts.reduce(add, 0)

      return {
        label,
        data: [{x: amounts.length, y: total}],
        pointRadius: scaleBetween(total, 2, 12, min, max),
        borderColor: rgba(colorValues[idx]),
        backgroundColor: rgba(colorValues[idx]),
      }
    })

  onMount(() => {
    const chart = Chart.Scatter(canvas, {
      data: {
        datasets,
      },
      options: {
        scales: {
          xAxes: [{
            gridLines: {
              drawOnChartArea: false,
            },
            ticks: {
              maxTicksLimit: 4,
              maxRotation: 0,
              minRotation: 0,
            },
          }],
          yAxes: [{
            gridLines: {
              drawOnChartArea: false,
            },
            ticks: {
              maxTicksLimit: 4,
              callback: dollars
            },
          }],
        },
      },
    })
  })
</script>

<canvas bind:this={canvas} />
