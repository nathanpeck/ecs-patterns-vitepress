<script setup>
import { storeToRefs } from "pinia"
import { useContentStore } from '../stores/content'

const store = useContentStore();
const { authors } = storeToRefs(store);
</script>

<template>
  <div class="author-wrapper">
    <div class="block">
      <h2>About this website</h2>
      <div class="block-card">
        <Content />
      </div>
    </div>
    <div class="block">
      <h2>The Team</h2>
      <div class="bigAuthor clearfix" v-for="authorDetails of authors">
        <div style="flex-grow: 1; display: flex; align-items: center;">
          <img class='authorImage' :alt='authorDetails.name + " profile picture"' :src="authorDetails.image" />
          <div class="meta">
            <b>{{ authorDetails.name }}</b> <br />
            <p>{{ authorDetails.title }}</p>
          </div>
        </div>
        <a :href="'/author/' + authorDetails.id" class="btn profileLink">Profile</a>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* These styles control the wrapper around the pattern page content */
.author-wrapper {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  background-color: var(--warm-content-bg);
  padding-top: 40px;
  padding-left: 20px;
  padding-right: 20px;
}

.block-card {
  border: 1px solid var(--bs-border-color-translucent);
  border-radius: 5px;
  background-color: var(--bs-tertiary-bg);
  padding: 40px;
}

.block {
  flex-grow: 1;
  align-items: center;
  width: 100%;
  max-width: 1000px;
  margin: 0 auto;
  margin-bottom: 20px;
}

.bigAuthor {
  display: flex;
  align-items: center;
  flex-grow: 1;
  flex-direction: row;
  flex-basis: align-items;
  justify-content: space-between;
  border: 1px solid var(--bs-border-color-translucent);
  border-radius: 5px;
  background-color: var(--bs-tertiary-bg);
  padding: 40px;
  padding-top: 20px;
  padding-bottom: 20px;
  width: 100%;
  max-width: 1000px;
  margin: 0 auto;
  margin-bottom: 20px;
}

.bigAuthor .authorImage {
  float: left;
  height: 100px;
  width: 100px;
  vertical-align: middle;
  border-radius: 100%;
  margin: 0px !important;
}

.bigAuthor .meta {
  padding-left: 20px;
}

.btn {
  font-weight: bold;
  background-color: rgb(var(--custom-highlight-color));
  color: white;
  padding: 5px;
  padding-left: 10px;
  padding-right: 10px;
  font-size: 1.1em;
  border-radius: 5px;
  margin-right: 10px;
  margin-top: 15px;
}

.btn.profileLink:hover,
.btn.profileLink:active {
  background-color: rgb(var(--custom-highlight-color), .85);
  color: white;
}
</style>
