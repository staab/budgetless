import {writable, readable} from 'svelte/store'
import {noop} from 'util/misc'

export const user = writable(null)

export const falseThenTrue = () =>
  readable(false, set => {
    setTimeout(() => set(true))

    return noop
  })

