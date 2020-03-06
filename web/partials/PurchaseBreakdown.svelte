<script>
  import Chart from 'chart.js'
  import {onMount} from 'svelte'
  import {DateTime} from 'luxon'
  import {range, dollars, colors, rgba, scaleBetween, add, dollarsk, last} from 'util/misc'

  export let transactions

  const canvases = {}

  const periodStart = DateTime.local().minus({days: 120})

  const days = []
  for (let i = 91; i > 0; i--) {
    days.push(DateTime.local().minus({days: i}))
  }

  const transactionsInPeriod = transactions
    .filter(({transaction_date, amount}) =>
      amount > 0 && periodStart < DateTime.fromISO(transaction_date)
    )

  const categories = transactionsInPeriod
    .map(({categories}) => last(categories))
    .filter((x, idx, self) => self.indexOf(x) === idx)

  const purchasesByCategory = transactionsInPeriod
    .reduce(
      (r, transaction) => {
        const k = last(transaction.categories)
        const v = r[k] || 0

        return {...r, [k]: v + 1}
      },
      {}
    )

  const sortedCategories = categories
    .sort((a, b) => purchasesByCategory[b] - purchasesByCategory[a])

  onMount(() => {
    sortedCategories.forEach(category => {
      const purchasesByDate = transactionsInPeriod
        .filter(({categories}) => last(categories) === category)
        .reduce(
          (r, {transaction_date, amount}) => {
            const k = DateTime.fromISO(transaction_date).toFormat('M/d')
            const v = r[k] || 0

            return {...r, [k]: v + amount}
          },
          {}
        )

      const getInterpolatedAverages = (max, step) => {
        // Get our weekly/monthly data first
        let data = range(0, max, step).map(day => {
          let n = 0
          const end = day + step - 1
          for (let i = day; i < end; i++) {
            const dt = DateTime.local().minus({days: i})

            n += purchasesByDate[dt.toFormat('M/d')] || 0
          }

          return n
        })

        // Now fill it in by averaging the difference between period points
        const interpolated = []
        for (let i = 0; i < max; i++) {
          if (i % step === 0) {
            interpolated.push(data[i / step])
          } else {
            const prev = data[(i - i % step) / step]
            const next = data[(i + (step - i % step)) / step]

            interpolated.push(prev + ((next - prev) / step) * (i % step))
          }
        }

        return interpolated
      }

      new Chart(canvases[category], {
        type: 'bar',
        data: {
          labels: days.map(dt => dt.toFormat('M/d')),
          datasets: [{
            borderColor: '#EDF2F7',
            backgroundColor: '#EDF2F7',
            data: days.map(dt => purchasesByDate[dt.toFormat('M/d')] || 0),
          }, {
            type: 'line',
            borderWidth: 2,
            borderColor: '#81E6D9',
            backgroundColor: 'rgba(0, 0, 0, 0)',
            data: getInterpolatedAverages(98, 7),
            pointRadius: 0,
            lineTension: 0,
            fill: false,
          }, {
            type: 'line',
            borderWidth: 2,
            borderColor: '#A3BFFA',
            backgroundColor: 'rgba(0, 0, 0, 0)',
            data: getInterpolatedAverages(120, 30),
            pointRadius: 0,
            lineTension: 0,
            fill: false,
          }],
        },
        options: {
          legend: {
            display: false,
          },
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
  })
</script>

{#each sortedCategories as category}
  <div class="flex">
    <div class="w-1/3">
      <h3>{category}</h3>
    </div>
    <div class="w-2/3">
      <canvas bind:this={canvases[category]} />
    </div>
  </div>
{/each}
