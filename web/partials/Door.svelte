<script>
  import {onMount} from 'svelte'

  let rectangle

  onMount(() => {
    const {width} = rectangle.getBoundingClientRect()

    rectangle.style = `height: ${width * 1.6}px; max-height: 82vh;`
  })
</script>

<style>
  .door {
    position: relative;
    background-color: rgba(255, 255, 255, 0.3);
  }

  /* https://stackoverflow.com/a/10423121/1467342 */
  .door::before {
    background-image: url('/public/images/mountain.jpg');
    background-size: cover;
    background-position: center center;
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    content: "";
    z-index: -1;
  }
</style>

<div class="door w-full h-screen p-2 sm:pt-16">
  <div bind:this={rectangle}
       class="bg-gray-800 text-white border-gray-600 rounded-lg
              shadow p-8 m-auto max-w-md">
    <h1 class="text-4xl text-teal-200 text-center my-6">Budgetless</h1>
    <slot />
  </div>
</div>
