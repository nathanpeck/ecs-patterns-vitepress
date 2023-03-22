<script setup lang="ts">
import { storeToRefs } from "pinia"
import { useContentStore } from '../stores/content'
import ContentListCard from './ContentListCard.vue'
import FillerCard from '../components/FillerCard.vue'

const contentStore = useContentStore();
const { labelledFilteredContent } = storeToRefs(contentStore);
</script>

<template>
  <div class="content">
    <ContentListCard v-for="content of labelledFilteredContent" :title="content.title" :description="content.description"
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
</template>


<style scoped>
.content {
  flex: 1;
  margin-top: 20px;
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
}
</style>