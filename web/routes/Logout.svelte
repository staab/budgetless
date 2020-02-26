<script>
  import {onMount} from 'svelte'
  import {navigate} from 'svelte-routing'
  import {user} from 'util/state'
  import {fetchJson} from 'util/misc'

  onMount(() => {
    fetchJson('POST', '/api/logout')

    user.set(null)

    navigate('/', {replace: true})
  })
</script>
