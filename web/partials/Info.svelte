<script>
  import {onMount} from 'svelte'
  import tippy from 'tippy.js'

  export let content

  let element

  onMount(() => tippy(element, {content}))
</script>

<span class="relative" bind:this={element}>
  <i
    class="fas fa-question-circle text-teal-200 cursor-pointer absolue top-0"
    style="transform: translate(0, -10%) scale(0.7);" />
</span>
