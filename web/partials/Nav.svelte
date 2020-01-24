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
    transition: left 200ms;
  }

  .open {
    left: 0;
  }
</style>

<nav class="h-10 bg-teal-300">
  <i class="fa fa-menu" on:click={toggle} />
</nav>
<div class="h-1 bg-gradient-1" />
<nav class="secondary-nav fixed" class:open>
  <Link to="/dashboard">Dashboard</Link>
  <Link to="/account">Account</Link>
  <Link to="/logout">Log Out</Link>
</nav>
