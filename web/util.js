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
