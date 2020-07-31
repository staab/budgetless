<script>
  import Chart from 'chart.js'
  import {onMount} from 'svelte'
  import {DateTime} from 'luxon'
  import {range, dollarsk} from 'util/misc'

  export let currentBalance
  export let transactions
  let chart, bbox

  const now = DateTime.local()
  const back30 = now.minus({days: 30})
  const back60 = now.minus({days: 60})

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
  let minY = currentBalance
  let maxY = currentBalance
  const labels = []
  const lines = [{
    label: 'Previous 30 Days',
    color: '#EDF2F7',
    data: [],
  }, {
    label: 'Last 30 Days',
    color: '#81E6D9',
    data: [],
  }]

  for (let i = 0; i < 60; i++) {
    const dtString = now.minus({days: i}).toFormat('M/d')

    balance += transactionsByDate[dtString] || 0
    minY = Math.min(balance, minY)
    maxY = Math.max(balance, maxY)

    if (i < 30) {
      lines[1].data.push(balance)
    } else {
      lines[0].data.push(balance)
      labels.push(dtString)
    }
  }

  // Reverse the lines so they're chronologically forward
  lines.map(line => line.data.reverse())

  const buildPath = xs => {
    const xScale = bbox.w / 29
    const yScale = bbox.h / (maxY - minY)

    return xs.map((v, i) => {
      const x = i * xScale
      const y = (maxY - v) * yScale

      return i === 0 ? `M ${x},${y}` : `${x},${y}`
    }).join(' ')
  }

  onMount(() => {
    const rect = chart.getBoundingClientRect()

    bbox = {
      w: rect.width,
      h: rect.width / 1.62,
    }
  })
</script>

<div class="-mr-8">
  {#each lines as line}
  <span class="inline-block whitespace-no-wrap text-xs">
    <span
      style={`background-color: ${line.color}; height: 3px; margin: 3px 0;`}
      class="inline-block w-4" />
    <span class="pl-1 pr-2">{line.label}</span>
  </span>
  {/each}
</div>
<div class="grid grid-cols-7">
  <div class="flex flex-col justify-between col-span-1 text-right mr-1">
    {#each range(minY, maxY, (maxY - minY) / 5).reverse() as y}
      <span class="text-xs text-gray-500">{dollarsk(y)}</span>
    {/each}
  </div>
  <div bind:this={chart} class="col-span-6 border border-solid border-gray-300">
    {#if bbox}
    <svg
      width={bbox.w}
      height={bbox.h}
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 {bbox.w} {bbox.h}">
      {#each lines as line}
        <path d={buildPath(line.data)} stroke={line.color} fill="transparent" stroke-width="2px" />
      {/each}
    </svg>
    {/if}
  </div>
  <div class="flex justify-between col-span-6 col-start-2">
    {#each range(0, 30, 6).reverse() as days}
      <span class="text-xs text-gray-500">
        {now.minus({days}).toFormat('M/d')}
      </span>
    {/each}
  </div>
</div>
