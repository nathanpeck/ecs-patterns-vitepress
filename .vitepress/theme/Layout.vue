<script setup lang="ts">
import { useData } from 'vitepress'
import { data as posts } from './loaders/posts.data.js'
import { data as loadedFilters } from './loaders/filters.data.js'
import { data as loadedFilterGroups } from './loaders/filter-groups.data.js'
import { data as loadedTeam } from './loaders/team.data.js'

import ContentList from './components/ContentList.vue'
import ContentListFilter from './components/ContentListFilter.vue'
import ContentPageSidebar from './components/ContentPageSidebar.vue'
import ContentPage from './components/ContentPage.vue'
import AuthorPage from './components/AuthorPage.vue'
import Header from './components/Header.vue'
import Footer from './components/Footer.vue'

import { useContentStore } from './stores/content'

const store = useContentStore();

store.team = loadedTeam;
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
  <Header />
  <div v-if="frontmatter.type == 'home'">
    <div class="container-fluid">
      <div class="wrapper">
        <ContentListFilter />
        <ContentList />
      </div>
    </div>
  </div>
  <div v-if="frontmatter.type == 'author'">
    <div class="container-fluid">
      <div class="wrapper">
        <AuthorPage />
      </div>
    </div>
  </div>
  <div v-if="frontmatter.title">
    <div class="container-fluid">
      <div class="wrapper">
        <ContentPageSidebar />
        <ContentPage />
      </div>
    </div>
  </div>
  <Footer />
</template>

<style scoped>
.wrapper {
  display: flex;
  flex-direction: row
}

/* On mobile width move the sidebar to the top
   and switch the layout to a column vs a side by side */
@media screen and (max-width: 600px) {
  .wrapper {
    flex-direction: column;
  }
}
</style>
