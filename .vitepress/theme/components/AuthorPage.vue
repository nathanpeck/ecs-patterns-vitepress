<script setup>
import { useData, useRoute } from 'vitepress'
import { storeToRefs } from "pinia"
import { useContentStore } from '../stores/content'

const { path } = useRoute();

const { frontmatter } = useData();
const authorId = frontmatter.value.authorId;

const store = useContentStore();
const { teamById } = storeToRefs(store);

let authorDetails = teamById.value[authorId];

if (!authorDetails) {
  throw new Error(`Failed to find team member ${authorId} in team.yml`)
}
</script>

<template>
  <div class="content">
    <div class="card content-card">
      <div class="card-body">
        <h1 class="title"><a :href="path">{{ authorDetails.name }}</a></h1>
        {{ authorDetails }}
      </div>
    </div>
  </div>
</template>

<style scoped>
.content {
  margin-top: 20px;
}
</style>