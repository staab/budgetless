<style>
  .door {
    position: relative;
  }

  /* https://stackoverflow.com/a/10423121/1467342 */
  .door::before {
    background-image: url('/public/images/tile_p3m1_v1.png');
    background-size: 50px;
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
  <div class="bg-gray-800 text-white border-gray-600 rounded
              shadow p-8 max-w-md m-auto">
    <h1 class="text-4xl text-teal-200 text-center my-6">Budgetless</h1>
    <slot />
  </div>
</div>
