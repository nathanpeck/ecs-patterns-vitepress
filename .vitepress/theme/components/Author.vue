<script setup>
import { storeToRefs } from "pinia"
import { useContentStore } from '../stores/content'
const { authorId } = defineProps(['authorId'])
const store = useContentStore();
const { authorsById } = storeToRefs(store);

let authorLink = `/author/${authorId}`
let authorDetails = authorsById.value[authorId];

if (!authorDetails) {
  throw new Error(`Failed to find team member ${authorId} in team.yml`)
}
</script>

<template>
  <div class="author clearfix">
    <a :href="authorLink" class="stretched-link" :aria-label='authorDetails.name + " profile page"'></a>
    <img class='authorImage' :alt='authorDetails.name + " profile picture"' :src="authorDetails.image" />
    <div class="meta">
      <b>{{ authorDetails.name }}</b> <br />
      {{ authorDetails.title }}
    </div>
  </div>
</template>

<style>
.author {
  position: relative;
  float: left;
  background-color: var(--bs-primary-bg-subtle);
  border: 1px solid var(--bs-primary-border-subtle);
  border-radius: 5px;
  max-width: 200px;
  padding: 0px;
  font-family: Arial, Helvetica, sans-serif;
  font-size: .75em;
  line-height: 1.1em;
  padding: 5px;
  display: flex;
  align-items: center;
  margin-right: 5px;
  margin-bottom: 5px;
}

.author .authorImage {
  float: left;
  height: 50px;
  width: 50px;
  vertical-align: middle;
  border-radius: 100%;
  margin: 0px !important;
}

.author .meta {
  padding-left: 10px;
}
</style>