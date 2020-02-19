export const fetchJson = async(method, url, body) => {
  const res = await fetch(url, {
    method,
    body: JSON.stringify(body),
    headers: {
      'Content-Type': 'application/json',
    },
  })

  if (res.status >= 500) {
    logError(res.statusText)

    return [null, {
      detail: "Oops! Something went wrong, please try again."
    }]
  }

  const result = {status: res.status, ...await res.json()}

  return res.status >= 400 ? [result, null] : [null, result]
}

export const logError = e => {
  if (window.onerror) {
    window.onerror(e)
  }

  console.error(e)
}
