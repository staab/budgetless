<script>
  import {Link} from 'svelte-routing'

  const year = new Date().getFullYear()
</script>

<nav class="p-4 bg-gray-800 text-gray-200 rajdhani font-hairline">
  <ul class="mb-6">
    <li class="py-1"><Link to="/about">About</Link></li>
    <li class="py-1"><a href="mailto:shtaab@gmail.com">Contact</a></li>
    <li class="py-1"><Link to="/login">Log In</Link></li>
  </ul>
  <small>All Rights Reserved. Copyright {year}, Jonathan Staab</small>
</nav>
