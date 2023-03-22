<script setup>
import { useRoute } from 'vitepress'
const { filename } = defineProps(['filename'])
const route = useRoute()
const imgUrl = `${route.path}/files/${filename}`;
</script>

<template>
  <div class="image-wrapper">
    <img :src="imgUrl" />
  </div>
</template>

<style scoped>
.image-wrapper img {
  max-width: 1000px;
}

@media screen and (max-width: 800px) {
  .image-wrapper img {
    max-width: 400px;
  }
}

@media screen and (max-width: 1000px) {
  .image-wrapper img {
    max-width: 500px;
  }
}

@media screen and (max-width: 1200px) {
  .image-wrapper img {
    max-width: 600px;
  }
}

@media screen and (max-width: 1400px) {
  .image-wrapper img {
    max-width: 700px;
  }
}
</style>