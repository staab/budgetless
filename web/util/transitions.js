import {cubicOut} from 'svelte/easing'

export const fadeUp = (node, opts) => ({
  duration: 500,
  easing: cubicOut,
  css: t => `opacity: ${t}; transform: translate(0, ${10 - t * 10}px)`,
  ...opts,
})


