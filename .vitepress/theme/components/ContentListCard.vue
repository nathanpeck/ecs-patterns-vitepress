<script setup>
const { tags } = defineProps(['title', 'description', 'image', 'tags', 'to', 'id'])
</script>

<template>
  <div class="card content-card">
    <!--<nuxt-img :src="`${id}/${image}`" class='card-img-top' />-->
    <div class="card-body">
      <h5 class="card-title">{{ title }}</h5>
      <p class="card-text">{{ description }}</p>
      <a :href="id" class="stretched-link"></a>
      <span class="badge rounded-pill tag" :style="{ 'background-color': tag.color }" v-for="tag in tags">{{ tag.label
      }}</span>
    </div>
  </div>
</template>

<style scoped>
.content-card {
  flex: 0 1 calc(25% - .5em);
  margin-bottom: 1em;
}

@media screen and (max-width: 1600px) {
  .content-card {
    flex: 0 1 calc(25% - .5em);
  }
}

@media screen and (max-width: 1400px) {
  .content-card {
    flex: 0 1 calc(33% - .5em);
  }
}

@media screen and (max-width: 1200px) {
  .content-card {
    flex: 0 1 calc(50% - .5em);
  }
}

@media screen and (max-width: 1000px) {
  .content-card {
    flex: 0 1 calc(100% - .5em);
  }
}

/* On mobile the content cards just take the full width of the column */
@media screen and (max-width: 600px) {
  .content-card {
    flex: 0 1 100%;
  }
}

.tag {
  margin-right: 5px;
}
</style>/*