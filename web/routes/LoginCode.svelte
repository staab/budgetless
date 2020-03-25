<script>
  import {parse} from 'qs'
  import {onMount} from 'svelte'
  import {Link, navigate} from "svelte-routing"
  import {fetchJson, logError} from 'util/misc'
  import {user} from 'util/state'
  import Door from 'partials/Door'
  import ExternalLink from 'partials/ExternalLink'

  const {email} = parse(window.location.search.slice(1))
  let login_code = ''
  let error = null
  let loading = false

  onMount(() => {
    if (!email) {
      navigate('/login/email')
    }
  })

  const onSubmit = async () => {
    loading = true

    const [e, r] = await fetchJson('post', '/api/login-with-code', {email, login_code})

    loading = false

    if (e) {
      error = e.data.detail
    } else {
      user.set(r.data)

      navigate("/dashboard")
    }
  }
</script>

<Door>
  <form on:submit|preventDefault={onSubmit}>
    <h2 class="text-2xl my-2">Next, check your email</h2>
    <p class="my-1">
      We just sent an email with a one-time login code
      to <strong>{email}</strong>. Enter it below and we'll get you
      signed in.
    </p>
    <div class="form-row text-lg">
      <input
        name="code"
        type="string"
        class="input w-full max-w-sm"
        class:bg-gray-300={loading}
        placeholder="Login Code"
        disabled={loading}
        bind:value={login_code} />
    </div>
    {#if error}
    <p class="my-1 text-red-700">{error}</p>
    {/if}
    <div class="text-right">
      <button class="button" disabled={loading}>Ok</button>
    </div>
  </form>
</Door>
ode
