<script setup>
import { computed, toRef } from "vue";
import { storeToRefs } from "pinia"
import { useContentStore } from '../stores/content'
import { withBase } from 'vitepress'
const props = defineProps(['authorId'])
const authorId = toRef(props, 'authorId');
const store = useContentStore();
const { authorsById } = storeToRefs(store);

let authorLink = `/author/${authorId.value}`
const authorDetails = computed(() => {
  return authorsById.value[authorId.value];
})

if (!authorDetails) {
  throw new Error(`Failed to find team member ${authorId} in team.yml`)
}
</script>

<template>
  <div class="author clearfix">
    <a :href="withBase(authorLink)" class="stretched-link" :aria-label='authorDetails.name + " profile page"'></a>
    <img class='authorImage' :alt='authorDetails.name + " profile picture"' :src="authorDetails.image" />
    <div class="meta">
      <b>{{ authorDetails.name }}</b> <br />
      {{ authorDetails.title }}
    </div>
  </div>
</template>

<style>
root,
[data-bs-theme=light] {
  --author-bg-color: rgb(210, 231, 245);
}

.author {
  position: relative;
  float: left;
  background-color: var(--author-bg-color);
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