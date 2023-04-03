<script setup>
import { useData } from 'vitepress'
import { storeToRefs } from "pinia"
import { useContentStore } from '../stores/content'
import Outline from '../components/Outline.vue'

const { frontmatter } = useData()
const store = useContentStore()
const { filtersByKeyValue, filterGroupsByKey } = storeToRefs(store);

var code = false;

// Precompute the labels for the dimensions
var dimensions = [];
if (frontmatter.value.filterDimensions) {
  dimensions = frontmatter.value.filterDimensions.map(function (dimension) {
    if (dimension.value == 'pattern' || dimension.value == 'script') {
      code = true;
    }

    const filterGroup = filterGroupsByKey.value[dimension.key];
    var filterGroupLabel;

    if (!filterGroup) {
      filterGroupLabel = `Label not found for '${dimension.key}''`;
    } else {
      filterGroupLabel = filterGroup.label
    }

    const filter = filtersByKeyValue.value[`${dimension.key}:${dimension.value}`];

    if (!filter) {
      filter = {
        label: `Filter not found: ${dimension.key}=${dimension.value}`
      };
    }

    return {
      filterGroupLabel,
      filter
    }
  })
}
</script>

<template>
  <div class="sidebar">
    <Outline />

    <div class="card">
      <div class="card-header">
        About
      </div>
      <div class="card-body">
        <div class="choice" v-for="dimension in dimensions">
          <h6>{{ dimension.filterGroupLabel }}</h6>
          <span class="badge rounded-pill" :style="{ 'background-color': dimension.filter.color }">{{
            dimension.filter.label }} </span>
        </div>
        <div class="choice" v-if="frontmatter.license">
          <h6>License</h6>
          <a :href="frontmatter.license.link">
            <span class="badge rounded-pill" :style="{ 'background-color': 'black' }">{{ frontmatter.license.label
            }}</span>
          </a>
        </div>
        <div class="choice" v-if="code && !frontmatter.license">
          <h6>License</h6>
          <a href="https://github.com/aws-samples/aws-cdk-changelogs-demo/blob/master/LICENSE">
            <span class="badge rounded-pill" :style="{ 'background-color': 'black' }">MIT No Attribution</span>
          </a>
        </div>
        <div class="choice" v-if="frontmatter.repositoryLink">
          <h6>Repository</h6>
          <a :href="frontmatter.repositoryLink">
            <span class="badge rounded-pill" :style="{ 'background-color': 'black' }">Github</span>
          </a>
        </div>
      </div>
    </div>

  </div>
</template>

<style scoped>
.header-text {
  font-size: 1.2em;
}

.sidebar {
  max-width: 300px;
  min-width: 300px;
  height: 100%;
  margin-right: 20px;
  margin-top: 20px;
}

/* On mobile hide this sidebar */
@media screen and (max-width: 900px) {
  .sidebar {
    width: 100%;
    max-width: none;
  }

}

.choice {
  margin-bottom: 10px;
  padding-bottom: 10px;
}

.choice:last-child {
  padding-bottom: none;
}
</style>