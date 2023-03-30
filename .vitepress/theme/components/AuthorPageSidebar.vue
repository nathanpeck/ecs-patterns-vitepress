<script setup>
import { useData } from 'vitepress'
import { storeToRefs } from "pinia"
import { useContentStore } from '../stores/content'

const { frontmatter } = useData();
const authorId = frontmatter.value.authorId;

const store = useContentStore();
const { authorsById } = storeToRefs(store);

let authorDetails = authorsById.value[authorId];

if (!authorDetails) {
  throw new Error(`Failed to find team member ${authorId} in team.yml`)
}
</script>

<template>
  <div class="sidebar">
    <div class="card content-card">
      <div class="card-body">
        <img :src="authorDetails.image" class="avatar" />
        <div class="name">{{ authorDetails.name }}</div>
        <div class="title">{{ authorDetails.title }}</div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.sidebar {
  max-width: 300px;
  min-width: 300px;
  height: 100%;
  float: left;
  margin-right: 20px;
  margin-top: 20px;
}

.name {
  text-align: center;
  font-size: 1.5em;
}

.avatar {
  border-radius: 100%;
  display: block;
  margin-left: auto;
  margin-right: auto;
  width: 75%;
}

.title {
  text-align: center;
}

/* On mobile make the sidebar take up the full width and push
   content cards to the bottom. */
@media screen and (max-width: 600px) {
  .sidebar {
    width: 100%;
    max-width: none;
    min-width: 100px;
  }

  .avatar {
    display: block;
    margin-left: auto;
    margin-right: auto;
    width: 50%;
  }
}
</style>