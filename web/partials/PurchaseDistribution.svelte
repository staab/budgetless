<script>
  import {onMount} from 'svelte'
  import {DateTime} from 'luxon'
  import {dollars, sum, avg, colors, rgba, scaleBetween, add, dollarsk, last} from 'util/misc'

  export let transactions
  let chart, bbox, points = []

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

  const colorValues = Object.values(colors)

  const totalInPeriod = transactionsInPeriod
    .reduce((r, {amount}) => r + amount, 0)

  const data = categories
    .sort((a, b) => sum(transactionsByCategory[b]) - sum(transactionsByCategory[a]))
    .slice(0, colorValues.length - 1)
    .map((label, idx) => ({label, idx, amounts: transactionsByCategory[label]}))

  const minX = data.reduce((r, {amounts}) => Math.min(r, amounts.length), Infinity)
  const maxX = data.reduce((r, {amounts}) => Math.max(r, amounts.length), 0)
  const minY = data.reduce((r, {amounts}) => Math.min(r, sum(amounts)), Infinity)
  const maxY = data.reduce((r, {amounts}) => Math.max(r, sum(amounts)), 0)

  onMount(() => {
    const rect = chart.getBoundingClientRect()

    bbox = {
      w: rect.width,
      h: rect.width / 1.62,
      vw: rect.width,
      vh: minY * ((rect.width / 1.62) / maxY),
    }

    console.log(bbox, maxY, minY)

    points = data.map(({label, amounts}, idx) => {
      const maxR = bbox.h / 10

      console.log(avg(amounts), maxR, bbox.h - maxR, minY, maxY, scaleBetween(avg(amounts), maxR, bbox.h - maxR, minY, maxY))

      return {
        label,
        x: scaleBetween(amounts.length, maxR, bbox.w - maxR, minX, maxX),
        y: scaleBetween(avg(amounts), maxR, bbox.h - maxR, minY, maxY),
        r: scaleBetween(sum(amounts), 4, maxR, minY, maxY),
      }
    })
  })

  //  onMount(() => {
  //    const chart = Chart.Scatter(canvas, {
  //      data: {
  //        datasets,
  //      },
  //      options: {
  //        scales: {
  //          xAxes: [{
  //            gridLines: {
  //              drawOnChartArea: false,
  //            },
  //            ticks: {
  //              maxTicksLimit: 4,
  //              maxRotation: 0,
  //              minRotation: 0,
  //            },
  //          }],
  //          yAxes: [{
  //            gridLines: {
  //              drawOnChartArea: false,
  //            },
  //            ticks: {
  //              maxTicksLimit: 4,
  //              callback: dollars
  //            },
  //          }],
  //        },
  //      },
  //    })
  //  })
</script>

<div bind:this={chart}>
  {#if bbox}
  <svg
    width={bbox.w}
    height={bbox.h}
    xmlns="http://www.w3.org/2000/svg"
    viewBox="0 0 {bbox.vw} {bbox.vh}">
    {#each points as point, i}
    <circle cx="{point.x}" cy="{point.y}" r="{point.r}" fill="{rgba(colorValues[i])}" />
    {/each}
  </svg>
  {/if}
</div>
