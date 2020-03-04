<script>
  import Chart from 'chart.js'
  import {onMount} from 'svelte'
  import {DateTime} from 'luxon'
  import {dollars, dollarsk} from 'util/misc'

  export let currentBalance
  export let transactions
  let canvas

  const back30 = DateTime.local().minus({days: 30})
  const back60 = DateTime.local().minus({days: 60})

  const transactionsByDate = transactions
    .filter(({transaction_date}) => back60 < DateTime.fromISO(transaction_date))
    .reduce(
      (r, {transaction_date, amount}) => {
        const s = DateTime.fromISO(transaction_date).toFormat('M/d')

        return {...r, [s]: (r[s] || 0) + amount}
      },
      {}
    )

  let balance = currentBalance
  const labels = []
  const thisPeriod = []
  const prevPeriod = []
  for (let i = 60; i > 0; i--) {
    const dtString = DateTime.local().minus({days: i}).toFormat('M/d')

    balance += transactionsByDate[dtString] || 0

    if (i > 30) {
      prevPeriod.push(balance)
    } else {
      thisPeriod.push(balance)
      labels.push(dtString)
    }
  }

  onMount(() => {
    const chart = new Chart(canvas, {
      type: 'line',
      data: {
        labels,
        datasets: [{
          data: thisPeriod,
          label: "Last 30 Days",
          pointRadius: 0,
          borderColor: '#81E6D9',
          backgroundColor: '#81E6D9',
          lineTension: 0,
          fill: false,
        }, {
          data: prevPeriod,
          label: "Previous 30 Days",
          pointRadius: 0,
          borderColor: '#EDF2F7',
          backgroundColor: '#EDF2F7',
          lineTension: 0,
          fill: false,
        }],
      },
      options: {
        tooltips: {
          mode: 'index',
          intersect: false,
          callbacks: {
            label: ({datasetIndex, yLabel}, data) => {
              const {label} = chart.data.datasets[datasetIndex]
              const value = dollars(yLabel)

              return `${label}: ${value}`
            }
          }
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
              callback: dollarsk
            },
          }],
        },
      },
    })
  })
</script>

<canvas bind:this={canvas} />
