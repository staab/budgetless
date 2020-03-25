<script>
  export let href
  export let color = 'n/a'
</script>

<a href={href} target="_blank" rel="noopener noreferer" class="link text-{color}">
  <slot />
</a>
