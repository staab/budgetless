<script>
  import {Link} from "svelte-routing"

  let open = false

  const toggle = () => {
    open = !open
  }
</script>

<style>
  .secondary-nav {
    left: -50rem;
    transition: left 300ms;
  }

  .open {
    left: 0;
  }

  nav > span {
    transition: background-color 200ms;
  }
</style>

<nav class="h-10 bg-teal-300 text-white p-2">
  <i class="fas fa-bars cursor-pointer" on:click={toggle} />
</nav>
<div class="h-1 bg-gradient-1" />
<nav
  class="secondary-nav fixed h-full bg-gray-800 flex flex-col text-white text-xl"
  class:open>
  <span class="cursor-pointer p-2 pl-4 pr-12 hover:bg-gray-900">
    <Link to="/dashboard">Dashboard</Link>
  </span>
  <span class="cursor-pointer p-2 pl-4 pr-12 hover:bg-gray-900">
    <Link to="/account">Account</Link>
  </span>
  <span class="cursor-pointer p-2 pl-4 pr-12 hover:bg-gray-900">
    <Link to="/logout">Log Out</Link>
  </span>
</nav>
