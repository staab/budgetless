export const fetchJson = async(method, url, body) => {
  const opts = {method}

  if (body) {
    Object.assign(opts, {
      body: JSON.stringify(body),
      headers: {
        'Content-Type': 'application/json',
      },
    })
  }

  const res = await fetch(url, opts)

  if (res.status >= 500) {
    logError(res.statusText)

    return [null, {
      detail: "Oops! Something went wrong, please try again."
    }]
  }

  const result = {status: res.status, data: await res.json()}

  return res.status >= 400 ? [result, null] : [null, result]
}

export const logError = e => {
  if (window.onerror) {
    window.onerror(e)
  }

  console.error(e)
}

export const addCommas = x =>
  x.toString().replace(/(\d)(?=(\d{3})+$)/g, '$1,')

export const dollars = x => '$' + addCommas(Math.round(x / 100))
