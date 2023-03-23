<script setup>
import { useData } from 'vitepress'
import { storeToRefs } from "pinia"
import { useContentStore } from '../stores/content'

const { frontmatter } = useData()
const store = useContentStore()
const { filtersByKeyValue, filterGroupsByKey } = storeToRefs(store);

var code = false;

// Precompute the labels for the dimensions
const dimensions = frontmatter.value.filterDimensions.map(function (dimension) {
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
</script>

<template>
  <div class="sidebar">
    <div class="card">
      <div class="card-header">
        <a href="/">&lt; Back to all patterns</a>
      </div>
      <div class="card-body">
        <div class="choice" v-for="dimension in dimensions">
          <h5>{{ dimension.filterGroupLabel }}</h5>
          <span class="badge rounded-pill" :style="{ 'background-color': dimension.filter.color }">{{
            dimension.filter.label }} </span>
        </div>
        <div class="choice" v-if="code">
          <h5>License</h5>
          <a href="https://github.com/aws-samples/aws-cdk-changelogs-demo/blob/master/LICENSE">
            <span class="badge rounded-pill" :style="{ 'background-color': 'black' }">MIT No Attribution</span>
          </a>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.sidebar {
  max-width: 300px;
  min-width: 300px;
  height: 100%;
  float: left;
  margin-right: 20px;
  margin-top: 20px;
}

.choice {
  margin-bottom: 10px;
  padding-bottom: 10px;
}

.choice:last-child {
  padding-bottom: none;
}
</style>