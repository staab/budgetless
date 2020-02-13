<script>
  import {Link} from "svelte-routing"
  import Footer from "partials/Footer.svelte"
</script>

<style>
  button {
    text-shadow: 0 1px 1px rgba(0, 0, 0, .25);
  }

  .hover\:bg-teal-400 {
    transition: background-color 200ms;
  }
</style>

<nav class="h-12 bg-teal-300" />
<div class="h-1 bg-gradient-1" />
<div class="text-center py-32">
  <h1 class="text-4xl font-semibold text-gray-800 leading-none">
    Welcome to <span class="underline">Budgetless</span>
  </h1>
  <h4 class="text-xl text-gray-800 mb-10">
    effortless personal finance
  </h4>
  <Link to="/signup">
    <button class="rounded bg-teal-300 border-2 border-teal-200
                   border-solid mb-2 px-6 py-3 text-white p-4 font-semibold
                   text-2xl hover:bg-teal-400 shadow-lg">
      Get Started
    </button>
  </Link>
  <div>
    Or, <span class="text-teal-400 underline">
      <Link to="/login/email">Log In</Link>
    </span>
  </div>
</div>
<div class="h-1 bg-gradient-2" />
<div class="pt-12 pb-4 bg-gray-800 text-white karla">
  <div class="max-w-md m-auto">
    <h1 class="text-3xl mb-8">
      Technology should inform <i>you</i>, not the other way around.
    </h1>
    <p class="mb-8">
      Most personal finance software makes you enter, categorize, and
      analyze your own spending. The idea is that busywork is the only
      way you’ll truly know where your money’s going.
    </p>
    <p>
      You’ve already lived your spending habits once, why do it again?
      We’re here to help you understand your spending habits.
    </p>
    <div class="py-12 pl-2 pr-16">
      <img src="/public/images/bubble-graph.png" alt="Bubble graph" />
    </div>
  </div>
</div>
<div class="h-1 bg-gradient-1" />
<div class="pt-12 pb-4 text-gray-800 karla">
  <div class="max-w-md m-auto">
    <h1 class="text-3xl mb-8">
      Have you ever tried to stick to a budget?
    </h1>
    <p class="mb-8">
      How long did it last? Budgeting is tedious at best, and even
      if you keep up, no two months are ever the same — one misstep,
      and you’re stuck with a broken budget and a guilty conscience.
    </p>
    <p>
      It takes time to build good spending habits. Seeing incremental
      improvement is more motivating than setting goals and falling short.
    </p>
    <p>
      We believe that practicing mindfulness of your spending habits is
      the key to controlling your finances.
    </p>
    <div class="py-12">
      <img src="/public/images/line-graph.png" alt="Line graph" />
    </div>
  </div>
</div>
<div class="h-1 bg-gradient-2" />
<div class="pt-12 pb-4 text-gray-800 bg-teal-100 karla">
  <div class="max-w-md m-auto">
    <h1 class="text-3xl text-center">
      Throw away your budget.
    </h1>
    <h4 class="text-lg mb-8 text-center">
      For only $3 per month!
    </h4>
  </div>
  <div class="max-w-sm m-auto">
    <ul class="list-disc">
      <li class="py-2">
        Automatically import account history from any US bank.
      </li>
      <li class="py-2">
        Share your account with multiple other people.
      </li>
      <li class="py-2">
        Categorize expenses automatically, or with manual overrides.
      </li>
      <li class="py-2">
        Use our compact, readable charts to help you understand your spending.
      </li>
    </ul>
  </div>
  <div class="text-center rajdhani mt-10 mb-8">
    <Link to="/signup">
      <button class="rounded bg-teal-300 border-2 border-teal-200
                     border-solid mb-2 px-6 py-3 text-white p-4 font-semibold
                     text-2xl hover:bg-teal-400 shadow-lg">
        Sign Up
      </button>
    </Link>
  </div>
</div>
<Footer />
