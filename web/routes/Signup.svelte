<script>
  import {Link} from "svelte-routing"
  import {logError} from 'util/misc'
  import Door from 'partials/Door'
  import ExternalLink from 'partials/ExternalLink'

  let email = ''
  let error = null
  let message = null

  const onSubmit = async () => {
    try {
      const res = await fetchJson('post', '/api/request-access', {email})

      if (res.status === 400) {
        error = res.detail
      } else {
        message = "Success! We'll let you know when Budgetless is ready."
        error = null
      }
    } catch (e) {
      logError(e)

      error = "Oops! Something went wrong, please try again."
    }
  }

  const loginDemo = () => console.log('hi')
</script>

<Door>
  <form on:submit|preventDefault={onSubmit}>
    <h2 class="text-2xl my-2">Budgetless is in private beta</h2>
    <p class="my-1">
      Registration is currently invite-only. Please enter your email
      address below and we’ll let you know if there are any open spots!
    </p>
    {#if message}
    <p class="my-1 font-semibold">{message}</p>
    <p class="my-1">
      <Link to="/"><i class="fas fa-arrow-left" /> Back to homepage</Link>
    </p>
    {:else}
    <div class="form-row text-lg">
      <input
        name="email"
        type="string"
        class="input w-full max-w-sm"
        placeholder="me@example.com"
        bind:value={email} />
    </div>
    {#if error}
    <p class="my-1 text-red-700">{error}</p>
    {/if}
    <p class="my-1">
      If you'd just like to see how Budgetless works, you can check
      out our <span on:click class="link">demo account</span>. You
      can also self-host! The source code can be found on
      <ExternalLink href="https://github.com/staab/budgetless">github</ExternalLink>.
    </p>
    <div class="text-right">
      <button class="button">Ok</button>
    </div>
    {/if}
  </form>
</Door>
