export const plaid = Plaid.create({
  clientName: 'Budgetless',
  countryCodes: ['US'],
  env: 'sandbox',
  key: process.env.PLAID_PUBLIC_KEY,
  product: ['transactions'],
  onSuccess: public_token =>
    fetch('/api/link', {
      method: 'POST',
      body: JSON.stringify({public_token}),
    }),
})

export const fetchJson = async(method, url, body) => {
  const res = await fetch(url, {
    method,
    body: JSON.stringify(body),
    headers: {
      'Content-Type': 'application/json',
    },
  })

  if (!res.ok || status >= 500) {
    throw res.statusText
  }

  return {status, ...await res.json()}
}

export const logError = e => {
  if (window.onerror) {
    window.onerror(e)
  }

  console.error(e)
}
