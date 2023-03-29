<script setup>
import Author from '../components/Author.vue'

import { useData, useRoute } from 'vitepress'
const { frontmatter, page } = useData();
const { path } = useRoute();
</script>

<template>
  <div class="content">
    <div class="card content-card">
      <div class="card-body">
        <h1 class="title"><a :href="path">{{ frontmatter.title }}</a></h1>
        <div class="authors clearfix">
          <Author v-for="author of frontmatter.authors" :authorId="author" />
        </div>
        <Content />
        <div class="content-meta">
          <div class="edit"><a href="#">
              <svg data-v-2d8bc1e6="" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" class="edit-icon"
                aria-label="edit icon">
                <path
                  d="M18,23H4c-1.7,0-3-1.3-3-3V6c0-1.7,1.3-3,3-3h7c0.6,0,1,0.4,1,1s-0.4,1-1,1H4C3.4,5,3,5.4,3,6v14c0,0.6,0.4,1,1,1h14c0.6,0,1-0.4,1-1v-7c0-0.6,0.4-1,1-1s1,0.4,1,1v7C21,21.7,19.7,23,18,23z">
                </path>
                <path
                  d="M8,17c-0.3,0-0.5-0.1-0.7-0.3C7,16.5,6.9,16.1,7,15.8l1-4c0-0.2,0.1-0.3,0.3-0.5l9.5-9.5c1.2-1.2,3.2-1.2,4.4,0c1.2,1.2,1.2,3.2,0,4.4l-9.5,9.5c-0.1,0.1-0.3,0.2-0.5,0.3l-4,1C8.2,17,8.1,17,8,17zM9.9,12.5l-0.5,2.1l2.1-0.5l9.3-9.3c0.4-0.4,0.4-1.1,0-1.6c-0.4-0.4-1.2-0.4-1.6,0l0,0L9.9,12.5z M18.5,2.5L18.5,2.5L18.5,2.5z">
                </path>
              </svg>
              Edit this page on Github</a></div>
          <div class="content-date" v-if="frontmatter.date">Updated {{ frontmatter.date }}</div>
        </div>
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

.authors {
  margin-bottom: 20px;
}

.title a {
  text-decoration: none;
  color: black;
}

.title a:hover {
  text-decoration: none;
  color: rgb(88, 88, 88);
}

.content-meta {
  font-size: .75em;
  margin-top: 30px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding-bottom: 14px;
}

.content-meta .edit {
  display: flex;
  align-items: center;
}

.edit-icon {
  width: 20px;
  vertical-align: middle;
  margin-right: 5px;
  display: inline;
}
</style>