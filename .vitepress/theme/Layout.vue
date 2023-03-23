<script setup lang="ts">
import { useData } from 'vitepress'
import { data as posts } from './loaders/posts.data.js'
import { data as loadedFilters } from './loaders/filters.data.js'
import { data as loadedFilterGroups } from './loaders/filter-groups.data.js'

import ContentList from './components/ContentList.vue'
import ContentListFilter from './components/ContentListFilter.vue'
import ContentPageSidebar from './components/ContentPageSidebar.vue'
import ContentPage from './components/ContentPage.vue'

import { useContentStore } from './stores/content'

const store = useContentStore();

store.filterGroups = loadedFilterGroups;
store.filters = loadedFilters;
store.content = posts.map((post) => {
  return {
    ...post.frontmatter,
    id: '/pattern/' + post.url.split('/')[2]
  }
})

// https://vitepress.dev/reference/runtime-api#usedata
const { site, frontmatter } = useData()
</script>

<template>
  <div v-if="frontmatter.home">
    <div class="container-fluid">
      <div class="wrapper">
        <ContentListFilter />
        <ContentList />
      </div>
    </div>
  </div>
  <div v-else>
    <div class="container-fluid">
      <div class="wrapper">
        <ContentPageSidebar />
        <ContentPage />
      </div>
    </div>
  </div>
</template>

<style scoped>
.wrapper {
  display: flex;
  flex-direction: row
}
</style>
