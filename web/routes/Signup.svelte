<script>
  import Door from 'partials/Door'
  import ExternalLink from 'partials/ExternalLink'

  let email = ''
  let error = null
  let message = null

  const onSubmit = async () => {
    try {
      const {status} = await fetch('/api/request-access', {
        method: 'post',
        body: JSON.stringify({email}),
      })

      if (status >= 300) {
        error = "Oops! Something went wrong, please try again."
      } else {
        message = "Success! We'll let you know when Budgetless is ready."
        error = null
      }
    } catch (e) {
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
    {:else}
    <div class="form-row text-lg">
      <span class="my-1 mx-2 absolute z-10 text-gray-700">@</span>
      <input
        name="email"
        type="string"
        class="input w-full max-w-sm"
        style="padding-left: 2rem;"
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
      <button class="button button-primary">Ok</button>
    </div>
    {/if}
  </form>
</Door>
