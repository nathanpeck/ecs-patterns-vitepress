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
/**
These styles ensure that the video stays at the 16:9 aspect ratio
A potential future improvement would be to support vertical story videos too
with another storyVideo class or similar.
 */
.videoWrapper {
  position: relative;
  padding-bottom: 56.25%;
  /* 16:9 */
  height: 0;
  margin-bottom: 1em;
}

.videoWrapper iframe {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
}
</style>