<script setup>
import { useData } from 'vitepress'
import { storeToRefs } from "pinia"
import { useContentStore } from '../stores/content'
import ContentListCard from './ContentListCard.vue'
import FillerCard from '../components/FillerCard.vue'

const { frontmatter } = useData();
const authorId = frontmatter.value.authorId;

const contentStore = useContentStore();
const { labelledContentByAuthor } = storeToRefs(contentStore);

const thisAuthorContent = labelledContentByAuthor.value[authorId];
</script>

<template>
  <div class="authorPageContent">
    <div class="content">
      <div class="card content-card">
        <div class="card-body">
          <Content />
        </div>
      </div>
    </div>
    <h2 class="label"> {{ thisAuthorContent.length }} items </h2>
    <div class="content authorContent">
      <ContentListCard v-for="content of thisAuthorContent" :title="content.title" :description="content.description"
        :image="content.image" :key="content.id" :tags="content.tags" :id="content.id" />

      <!-- Solve the "last row" problem of flexbox-->
      <FillerCard />
      <FillerCard />
      <FillerCard />
      <FillerCard />
      <FillerCard />
      <FillerCard />
      <FillerCard />
      <FillerCard />
      <FillerCard />
    </div>
  </div>
</template>

<style scoped>
.authorPageContent {
  display: flex;
  flex-direction: column
}

.authorContent {
  margin-top: 20px;
}

.content {
  min-width: 500px;
  max-width: 1100px;
  flex-grow: 1;
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
}

.name {
  text-align: center;
  font-size: 2em;
}

.avatar {
  border-radius: 100%;
  width: 100%;
}

.title {
  text-align: center;
}

.label {
  margin-top: 20px;
  padding-bottom: 0px;
  margin-bottom: 0px;
}
</style>