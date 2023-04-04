<script setup lang="ts">
import { storeToRefs } from "pinia"
import { useContentStore } from '../stores/content'
import FilterGroup from '../components/FilterGroup.vue'

const contentStore = useContentStore();
const { filterList, labelledFilteredContent } = storeToRefs(contentStore);
const { resetAllFilters } = contentStore;
</script>

<template>
  <div class="sidebar">
    <div class="card">
      <div class="card-header">
        Filter ({{ labelledFilteredContent.length }} results)
        <button class="btn btn-sm btn-secondary float-right" @click="resetAllFilters">
          Reset
        </button>
      </div>
      <div class="card-body">
        <form>
          <FilterGroup v-for="filterGroup of filterList" :label="filterGroup.label" :filters="filterGroup.filters"
            :key="filterGroup.key" />
        </form>
      </div>
    </div>
    <div class="card">
      <div class="card-body">
        <a href="https://main--prismatic-babka-239bef.netlify.app/">ECS Newsletter</a>
      </div>
    </div>
  </div>
</template>

<style scoped>
.card {
  margin-bottom: 20px;
}

.choice {
  margin-bottom: 10px;
  padding-bottom: 10px;
  border-bottom: 1px solid #CCC
}

.choice:last-child {
  border-bottom: none;
}

.float-right {
  float: right !important
}

.header-text {
  font-size: 1.2em;
}

.sidebar {
  height: 100%;
  float: left;
  margin-right: 20px;
  padding-bottom: 20px;
  max-width: 300px;
  min-width: 300px;
}

/* On mobile make the sidebar take up the full width and push
   content cards to the bottom. */
@media screen and (max-width: 600px) {
  .sidebar {
    width: 100%;
    max-width: none;
    min-width: 100px;
  }
}
</style>