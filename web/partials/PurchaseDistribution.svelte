<script>
  import {onMount} from 'svelte'
  import {DateTime} from 'luxon'
  import {
    dollars, sum, avg, colors, rgba, scaleBetween, add, dollarsk, last,
    range, concat, prop, pluralize,
  } from 'util/misc'

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
  const minY = data.reduce((r, {amounts}) => Math.min(r, avg(amounts)), Infinity)
  const maxY = data.reduce((r, {amounts}) => Math.max(r, avg(amounts)), 0)
  const minSum = data.reduce((r, {amounts}) => Math.min(r, sum(amounts)), Infinity)
  const maxSum = data.reduce((r, {amounts}) => Math.max(r, sum(amounts)), 0)
  const xStep = (maxX - minX) / 3
  const yStep = (maxY - minY) / 3

  onMount(() => {
    if (chart) {
      const rect = chart.getBoundingClientRect()

      bbox = {
        w: rect.width,
        h: rect.width / 1.62,
      }

      points = data.map(({label, amounts}, idx) => {
        const maxR = bbox.h / 8

        return {
          label,
          color: rgba(colorValues[idx]),
          x: scaleBetween(amounts.length, maxR, bbox.w - maxR, minX, maxX),
          y: scaleBetween(maxY - avg(amounts) + minY, maxR, bbox.h - maxR, minY, maxY),
          r: scaleBetween(sum(amounts), maxR / 3, maxR - 1, minSum, maxSum),
        }
      })
    }
  })
</script>

{#if maxY === 0}
<small>No data found.</small>
{:else}
<div class="-mr-8">
  {#each points as point}
  <span class="inline-block whitespace-no-wrap text-xs">
    <span
      style={`background-color: ${point.color}; height: 3px; margin: 3px 0;`}
      class="inline-block w-4" />
    <span class="pl-1 pr-2">{point.label}</span>
  </span>
  {/each}
</div>
<div class="grid grid-cols-7">
  <div class="flex flex-col justify-around col-span-1 text-right mr-1">
    {#each range(minY, maxY, yStep).reverse() as y}
      <span class="text-xs text-gray-500">{dollars(y)}</span>
    {/each}
  </div>
  <div bind:this={chart} class="col-span-6 border border-solid border-gray-300">
    {#if bbox}
    <svg
      width={bbox.w}
      height={bbox.h}
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 {bbox.w} {bbox.h}">
      {#each points as point}
      <circle cx="{point.x}" cy="{point.y}" r="{point.r}" fill="{point.color}" />
      {/each}
    </svg>
    {/if}
  </div>
  <div class="flex justify-between col-span-6 col-start-2">
    {#each range(minX, maxX, xStep) as y}
      <span class="text-xs text-gray-500">
        {Math.round(y)} {pluralize(y, 'purchase')}
      </span>
    {/each}
  </div>
</div>
{/if}
