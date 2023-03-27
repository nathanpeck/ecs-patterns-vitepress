<script setup>
import { storeToRefs } from "pinia"
import { useContentStore } from '../stores/content'
const { authorId } = defineProps(['authorId'])
const store = useContentStore();
const { teamById } = storeToRefs(store);

let authorDetails = teamById.value[authorId];

if (!authorDetails) {
  throw new Error(`Failed to find team member ${authorId} in team.yml`)
}
</script>

<template>
  <div class="author clearfix">
    <img :src="authorDetails.image" />
    <div class="meta">
      <b>{{ authorDetails.name }}</b> <br />
      {{ authorDetails.title }}
    </div>
  </div>
</template>

<style>
.author {
  float: left;
  background-color: rgb(210, 231, 245);
  border-radius: 5px;
  max-width: 190px;
  padding: 0px;
  font-family: Arial, Helvetica, sans-serif;
  font-size: .75em;
  line-height: 1.1em;
  padding: 5px;
  display: flex;
  align-items: center;
  margin-bottom: 20px;
  margin-right: 5px;
}

.author::after {
  display: block;
  clear: both;
  content: "";
}

.author img {
  float: left;
  height: 50px;
  vertical-align: middle;
  border-radius: 100%;
  margin: 0px !important;
}

.author .meta {
  padding-left: 10px;
}
</style>