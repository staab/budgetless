<script>
  import {onMount} from 'svelte'
  import Nav from 'partials/Nav.svelte'
  import {user} from 'util/state'
  import {navigate} from 'svelte-routing'

  onMount(() => {
    if (!$user.plaid_item_id) {
      navigate('/plaid/link')
    }
  })
</script>

<Nav />
Crashboard
{$user.email}
