<script setup lang="ts">
import { computed, ref } from 'vue'
import { storeToRefs } from "pinia"
import { useContentStore } from '../stores/content'
import ContentListCard from './ContentListCard.vue'
import FillerCard from '../components/FillerCard.vue'

const contentStore = useContentStore();
const { labelledFilteredContent } = storeToRefs(contentStore);

// Sort the content by its date descending
const sortedLabelledFilteredContent = computed(() => {
  return [...labelledFilteredContent.value].sort(function (left, right) {
    const leftDate = new Date(left.date).getTime();
    const rightDate = new Date(right.date).getTime();

    if (leftDate < rightDate) {
      return 1;
    }

    if (leftDate > rightDate) {
      return -1;
    }

    return 0;
  })
})

const searchTerm = ref('')

const displayContent = computed(() => {
  // If the search term is too short return all content
  if (searchTerm.value.length < 2) {
    return sortedLabelledFilteredContent.value;
  }

  const search = new RegExp(searchTerm.value, "i")

  return sortedLabelledFilteredContent.value.filter(function (content) {
    if (content.title.match(search)) {
      return true;
    }

    if (content.description.match(search)) {
      return true;
    }

    for (const tag of content.tags) {
      if (tag.label.match(search)) {
        return true;
      }
    }

    for (const authorDetail of content.authorDetails) {
      if (authorDetail.name.match(search)) {
        return true;
      }
    }

    return false;
  });
})
</script>

<template>
  <div class="content">
    <div class="search-wrapper">
      <input type="search" class="form-control searcher" placeholder="Search..." v-model="searchTerm" />
    </div>
    <div class="results" v-if="displayContent.length > 0">
      <ContentListCard v-for="content of displayContent" :title="content.title" :description="content.description"
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
    <div class="content" v-if="displayContent.length == 0">
      <div class="card content-card nothing-found">
        <div class="card-body">
          <h2>Nothing found!</h2>
          <p>
            Unfortunately no matches were found for your selected filters.
            Try unselecting some of the filters from the left sidebar, or use
            the Reset button to turn off all filters and see all content again.
            Or try clearing the keyword search field above.
          </p>
          <p>
            If you have a code snippet that you'd like to submit, or would like
            to request that a particular pattern be created, please open an issue on
            our Github repo.
          </p>
        </div>
      </div>
    </div>
  </div>
</template>


<style scoped>
.content {
  margin-top: 20px;
}

.results {
  margin-top: 20px;
  display: flex;
  flex-wrap: wrap;
  justify-content: space-between;
  justify-items: stretch;
}

.nothing-found {
  align-self: start;
  height: auto;
}

.searcher {
  padding: .75rem 1rem;
}
</style>