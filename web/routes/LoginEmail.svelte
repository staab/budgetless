<script>
  import {Link, navigate} from "svelte-routing"
  import {fetchJson, logError} from 'util/misc'
  import Door from 'partials/Door'
  import ExternalLink from 'partials/ExternalLink'

  let email = ''
  let error = null

  const onSubmit = async () => {
    try {
      const res = await fetchJson('post', '/api/send-login-code', {email})

      if (res.status === 400) {
        error = res.detail
      } else {
        navigate("/login/code")
      }
    } catch (e) {
      logError(e)

      error = "Oops! Something went wrong, please try again."
    }
  }
</script>

<Door>
  <form on:submit|preventDefault={onSubmit}>
    <h2 class="text-2xl my-2">First, enter your email address</h2>
    <p class="my-1">
      All communications are opt-in. We don't share your information unless
      you ask us to.
    </p>
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
    <div class="text-right">
      <button class="button">Ok</button>
    </div>
  </form>
</Door>
