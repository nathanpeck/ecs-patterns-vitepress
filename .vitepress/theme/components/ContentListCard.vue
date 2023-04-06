<script setup>
const { tags } = defineProps(['title', 'description', 'image', 'tags', 'to', 'id'])
</script>

<template>
  <div class="card content-list-card">
    <!--<nuxt-img :src="`${id}/${image}`" class='card-img-top' />-->
    <div class="card-body">
      <h5 class="card-title">{{ title }}</h5>
      <p class="card-text">{{ description }}</p>
      <a :href="id" class="stretched-link" :aria-label="title" />
      <span class="badge rounded-pill tag" :style="{ 'background-color': tag.color }" v-for="tag in tags">{{ tag.label
      }}</span>
    </div>
  </div>
</template>

<style>
.content-list-card {
  flex: 0 1 calc(25% - .5em);
  margin-bottom: 1em;
}

.content-list-card .card-title {
  color: var(--bs-emphasis-color)
}

@media screen and (max-width: 1600px) {
  .content-list-card {
    flex: 0 1 calc(25% - .7em);
  }
}

@media screen and (max-width: 1400px) {
  .content-list-card {
    flex: 0 1 calc(33% - .6em);
  }
}

@media screen and (max-width: 1200px) {
  .content-list-card {
    flex: 0 1 calc(50% - .5em);
  }
}

@media screen and (max-width: 1000px) {
  .content-list-card {
    flex: 0 1 calc(100%);
  }
}

/* On mobile the content cards just take the full width of the column */
@media screen and (max-width: 600px) {
  .content-list-card {
    flex: 0 1 100%;
  }
}

.tag {
  margin-right: 5px;
}
</style>/*