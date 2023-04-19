<script setup>
import { ref, onMounted, watchEffect } from 'vue';
import Author from '../components/Author.vue'

import { useData, useRoute } from 'vitepress'
const { frontmatter } = useData();
const { path } = useRoute();

const date = new Date(frontmatter.value.date)
const datetime = ref('')

// This hook hook updates the date string to match the end user's desired
// date format based on the localization of their browser. It happens in a
// mount hook because this will ensure that it doesn't cause a hydration
// mismatch between the server rendered version of the page and the client
// side version of the page.
onMounted(() => {
  watchEffect(() => {
    datetime.value = date.toLocaleString(window.navigator.language, { dateStyle: 'medium' })
  })
})

const githubPath = `https://github.com/nathanpeck/ecs-patterns-vitepress/tree/main/${path}/index.md`;
</script>

<template>
  <div class="content">
    <div class="content-inner-card">
      <h1 class="title"><a :href="path">{{ frontmatter.title }}</a></h1>
      <div class="authors clearfix">
        <Author v-for="author of frontmatter.authors" :authorId="author" />
      </div>
      <Content />
      <div class="content-meta">
        <div class="edit"><a :href="githubPath">
            <svg data-v-2d8bc1e6="" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" class="edit-icon"
              aria-label="edit icon">
              <path
                d="M18,23H4c-1.7,0-3-1.3-3-3V6c0-1.7,1.3-3,3-3h7c0.6,0,1,0.4,1,1s-0.4,1-1,1H4C3.4,5,3,5.4,3,6v14c0,0.6,0.4,1,1,1h14c0.6,0,1-0.4,1-1v-7c0-0.6,0.4-1,1-1s1,0.4,1,1v7C21,21.7,19.7,23,18,23z">
              </path>
              <path
                d="M8,17c-0.3,0-0.5-0.1-0.7-0.3C7,16.5,6.9,16.1,7,15.8l1-4c0-0.2,0.1-0.3,0.3-0.5l9.5-9.5c1.2-1.2,3.2-1.2,4.4,0c1.2,1.2,1.2,3.2,0,4.4l-9.5,9.5c-0.1,0.1-0.3,0.2-0.5,0.3l-4,1C8.2,17,8.1,17,8,17zM9.9,12.5l-0.5,2.1l2.1-0.5l9.3-9.3c0.4-0.4,0.4-1.1,0-1.6c-0.4-0.4-1.2-0.4-1.6,0l0,0L9.9,12.5z M18.5,2.5L18.5,2.5L18.5,2.5z">
              </path>
            </svg>Edit this page on Github</a></div>
        <div class="content-date" v-if="frontmatter.date">Last Updated {{ datetime }}</div>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* These styles control the wrapper around the pattern page content */
.content {
  max-width: 1100px;
  min-width: 100px;
  width: auto;
}
</style>

<style>
.content-inner-card {
  padding-top: 30px;
  padding-left: 40px;
  padding-right: 40px;
  margin-top: 20px;
  margin-right: 20px;
  margin-bottom: 20px;
  word-wrap: break-word;
  background-color: var(--bs-body-bg);
  background-clip: border-box;
  border: var(--bs-border-width) solid var(--bs-border-color-translucent);
  border-radius: var(--bs-border-radius);
}

@media screen and (max-width: 900px) {
  .content-inner-card {
    padding: 30px;
    margin-top: 0px;
    margin-left: 20px;
  }
}

@media screen and (max-width: 700px) {
  .content-inner-card {
    padding: 20px;
    margin: 0px;
    border-radius: 0;
    border-left: none;
    border-right: none;
    border-bottom: none;
  }
}

/** These styles clean up the presentation of the text and images
inside of each pattern page */
h2 {
  padding-bottom: .75em;
}

h4 {
  padding-top: .5em;
  padding-bottom: .5em;
}

table {
  margin-bottom: 1.2em;
}

.content ul li {
  list-style: disc;
}

.content ol li {
  list-style-type: decimal;
  list-style: auto;
}

.content img {
  max-width: 1000px;
  width: 100%;
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

.content p {
  /*color: var(--bs-body-color)*/
}

.authors {
  margin-bottom: 20px;
}

.title {
  margin-bottom: 20px;
}

.title a {
  text-decoration: none;
  color: var(--bs-emphasis-color);
}

.title a:hover {
  text-decoration: none;
  color: var(--bs-body-color);
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
  fill: var(--bs-emphasis-color);
  width: 17px;
  vertical-align: middle;
  margin-right: 5px;
  display: inline;
}

.custom-block {
  margin-bottom: 20px;
}

/** The magical # anchor that appears on headings in the content
    on hover. */
.header-anchor {
  float: left;
  margin-left: -.87em;
  padding-right: .23em;
  font-weight: 500;
  opacity: 0;
  transition: color .25s, opacity .25s;
  text-decoration: none;
}

.header-anchor:before {
  content: "#"
}

h1:hover .header-anchor,
h1 .header-anchor:focus,
h2:hover .header-anchor,
h2 .header-anchor:focus,
h3:hover .header-anchor,
h3 .header-anchor:focus,
h4:hover .header-anchor,
h4 .header-anchor:focus,
h5:hover .header-anchor,
h5 .header-anchor:focus,
h6:hover .header-anchor,
h6 .header-anchor:focus {
  opacity: 1
}

.content .custom-block {
  background-color: var(--bs-tertiary-bg);
}

.content .custom-block code {
  background-color: var(--bs-secondary-bg);
  padding: 4px;
}
</style>