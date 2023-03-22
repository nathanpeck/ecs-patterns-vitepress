<script setup>
const { id } = defineProps(['id'])

const videoUrl = `https://www.youtube.com/embed/${id}`
</script>

<template>
  <div class="videoWrapper">
    <iframe width="560" height="315" :src="videoUrl" title="YouTube video player" frameborder="0"
      allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
      allowfullscreen></iframe>
  </div>
</template>

<style scoped>
.videoWrapper {
  position: relative;
  padding-bottom: 56.25%;
  /* 16:9 */
  height: 0;
}

.videoWrapper iframe {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
}
</style>