<script setup>
import Author from '../components/Author.vue'

import { useData } from 'vitepress'
const { frontmatter } = useData();
</script>

<template>
  <div class="content">
    <div class="card content-card">
      <div class="card-body">
        <h1>{{ frontmatter.title }}</h1>
        <Author v-for="author of frontmatter.authors" :authorId="author" />
        <div class="clearfix"></div>
        <Content />
      </div>
    </div>
  </div>
</template>

<style scoped>
/* These styles control the wrapper around the pattern page content */
.content {
  flex: 1;
  margin-top: 20px;
  min-width: 500px;
  max-width: 1100px;
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
}

.card-body {
  padding-top: 30px;
  padding-left: 40px;
  padding-right: 40px;
}
</style>

<style>
/** These styles clean up the presentation of the text and images
inside of each pattern page */
h2 {
  padding-bottom: .75em;
}

h4 {
  padding-bottom: .5em;
}

table {
  margin-bottom: 1.2em;
}

.content img {
  max-width: 1000px;
  margin-top: 20px;
  margin-bottom: 20px;
}

@media screen and (max-width: 800px) {
  .content img {
    max-width: 400px;
  }
}

@media screen and (max-width: 1000px) {
  .content img {
    max-width: 500px;
  }
}

@media screen and (max-width: 1200px) {
  .content img {
    max-width: 600px;
  }
}

@media screen and (max-width: 1400px) {
  .content img {
    max-width: 700px;
  }
}
</style>