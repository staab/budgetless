<script>
  import {onMount} from 'svelte'
  import Nav from 'partials/Nav.svelte'
  import {user} from 'util/state'
  import {fetchJson} from 'util/misc'
  import {navigate} from 'svelte-routing'

  let loading = true

  onMount(async () => {
    if (!$user.plaid_item_id) {
      navigate('/plaid/link')
    }

    const [_, {data}] = await fetchJson('GET', '/api/dashboard')

    console.log(data)
  })
</script>

<Nav />
<div class="flex max-w-md m-auto p-4">
  {#if loading}
  <div class="w-full flex justify-center">
    <h2 class="text-lg mt-12">Loading...</h2>
  </div>
  {:else}
  Crashboard
  {$user.email}
  {/if}
</div>
