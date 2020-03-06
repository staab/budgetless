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

export const last = xs => xs.slice(-1)[0]

export const add = (a, b) => a + b

export const addCommas = x =>
  x.toString().replace(/(\d)(?=(\d{3})+$)/g, '$1,')

export const dollars = x => '$' + addCommas(Math.round(x / 100))

export const dollarsk = x => {
  if (x < 1000000) {
    return dollars(x)
  }

  const fraction = (x % 10000) / 10000

  return dollars(x).replace(/,\d{3}$/, `.${fraction}k`)
}

//  https://stackoverflow.com/a/31687097
export const scaleBetween = (unscaledNum, minAllowed, maxAllowed, min, max) =>
  (maxAllowed - minAllowed) * (unscaledNum - min) / (max - min) + minAllowed

export const colors = {
  red:    [254, 178, 178],
  yellow: [250, 240, 137],
  green:  [154, 230, 180],
  teal:   [129, 230, 217],
  blue:   [144, 205, 244],
  indigo: [163, 191, 250],
  purple: [214, 288, 250],
  pink:   [251, 182, 206],
  orange: [251, 211, 141],
}

export const rgba = (color, opacity = 1) => `rgba(${color.join(',')}, ${opacity})`

export const range = (start, stop, step = 1) => {
  const r = []
  for (let i = start; (step > 0 ? i < stop : i > stop); i += step) {
    r.push(i)
  }

  return r
}
