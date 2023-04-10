<script setup lang="ts">
import { useData } from 'vitepress'
import { data as posts } from './loaders/posts.data.js'
import { data as loadedFilters } from './loaders/filters.data.js'
import { data as loadedFilterGroups } from './loaders/filter-groups.data.js'
import { data as loadedAuthors } from './loaders/authors.data.js'

import ContentList from './components/ContentList.vue'
import ContentListFilter from './components/ContentListFilter.vue'
import ContentPageSidebar from './components/ContentPageSidebar.vue'
import ContentPage from './components/ContentPage.vue'
import AuthorPageSidebar from './components/AuthorPageSidebar.vue'
import AuthorPage from './components/AuthorPage.vue'
import Header from './components/Header.vue'
import Footer from './components/Footer.vue'
import Home from './components/Home.vue'

import { storeToRefs } from "pinia"
import { onBeforeMount, watch } from "vue"
import { useContentStore } from './stores/content'

const store = useContentStore();

const { themeSetting } = storeToRefs(store)

themeSetting.value = themeSetting.value

store.authors = loadedAuthors;
store.filterGroups = loadedFilterGroups;
store.filters = loadedFilters;
store.content = posts.map((post) => {
  return {
    ...post.frontmatter,
    id: '/pattern/' + post.url.split('/')[2]
  }
})

onBeforeMount(() => {
  document.body.setAttribute('data-bs-theme', themeSetting.value)
})

watch(themeSetting, () => {
  document.body.setAttribute('data-bs-theme', themeSetting.value)
})

// https://vitepress.dev/reference/runtime-api#usedata
const { frontmatter, page } = useData()

/*console.log('frontmatter', frontmatter.value);
console.log('page', page.value);*/

</script>

<template>
  <div>
    <Header />
    <div v-if="frontmatter.type == 'home'">
      <Home />
    </div>
    <div v-else-if="frontmatter.type == 'pattern-list'">
      <div class="container-fluid">
        <div class="wrapper">
          <ContentListFilter />
          <ContentList />
        </div>
      </div>
    </div>
    <div v-else-if="frontmatter.type == 'page'">
      <div class="container-fluid">
        <div class="wrapper">
          <ContentPage />
        </div>
      </div>
    </div>
    <div v-else-if="frontmatter.type == 'author'">
      <div class="container-fluid">
        <div class="wrapper">
          <AuthorPageSidebar />
          <AuthorPage />
        </div>
      </div>
    </div>
    <div v-else-if="frontmatter.type == 'pattern' || frontmatter.filterDimensions">
      <div class="container-fluid">
        <div class="wide-wrapper">
          <ContentPageSidebar />
          <ContentPage />
        </div>
      </div>
    </div>
    <Footer />
  </div>
</template>

<style scoped>
.container-fluid {
  margin: 0px;
  padding: 0px;
}

.wrapper {
  display: flex;
  flex-direction: row;
  padding-left: 20px;
  padding-right: 20px;
  padding-bottom: 20px;
  padding-top: 20px;
  background-color: var(--warm-content-bg);
}

/* On mobile width move the sidebar to the top
   and switch the layout to a column vs a side by side */
@media screen and (max-width: 600px) {
  .wrapper {
    flex-direction: column;
  }
}

.wide-wrapper {
  display: flex;
  flex-direction: row;
  padding-left: 20px;
  padding-right: 20px;
  padding-bottom: 20px;
  padding-top: 20px;
  background-color: var(--warm-content-bg);
}

/* On mobile width move the sidebar to the top
   and switch the layout to a column vs a side by side */
@media screen and (max-width: 900px) {
  .wide-wrapper {
    flex-direction: column;
  }
}
</style>
