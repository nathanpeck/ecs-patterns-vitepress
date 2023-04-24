<script setup>
import { ref } from 'vue'
import { useData } from 'vitepress'
import { storeToRefs } from "pinia"
import { useContentStore } from '../stores/content'
import Outline from '../components/Outline.vue'
import CollapsibleSidebarSection from '../components/CollapsibleSidebarSection.vue'
import { getHeaders } from './composables/outline';
import { onContentUpdated } from 'vitepress'

const { frontmatter } = useData()
const store = useContentStore()
const { filtersByKeyValue, filterGroupsByKey } = storeToRefs(store);

const headers = ref([]);

onContentUpdated(() => {
  headers.value = getHeaders();
})

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
    <a class='btn back-button' href="/">Back to all patterns</a>
    <CollapsibleSidebarSection title="Table of Contents" v-if="headers.length > 0">
      <Outline :headers="headers" />
    </CollapsibleSidebarSection>
    <CollapsibleSidebarSection title="About">
      <div class="choices">
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

    </CollapsibleSidebarSection>
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
  margin-top: 20px;
  margin-left: 20px;
  margin-right: 20px;
  margin-bottom: none;
}

.choices {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  justify-content: space-between;
  row-gap: 10px;
}

.choice {
  width: 100%;
}

.choice:last-child {
  padding-bottom: none;
}

.back-button {
  background-color: rgb(var(--custom-highlight-color));
  width: 100%;
  color: white;
  margin-bottom: 20px;
}

@media screen and (max-width: 700px) {
  .back-button {
    margin-bottom: 10px;
  }
}

.back-button:hover,
.back-botton:active {
  background-color: rgb(var(--custom-highlight-color), .85);
  color: white;
}

/* On mobile adjust sidebar to horizontal configuration */
@media screen and (max-width: 900px) {
  .sidebar {
    width: 100%;
    max-width: none;
  }

  .choice {
    flex: 0 1 calc(25% - .5em);
  }

  .back-button {
    float: left;
    width: auto;
    margin-right: 10px;
    font-size: 1em;
    padding: 8px;
  }
}

@media screen and (max-width: 700px) {
  .choice {
    flex: 0 1 calc(50% - .5em);
  }

  .sidebar {
    margin-top: 10px;
    margin-left: 10px;
    margin-right: 10px;
  }

  .choices {
    row-gap: 10px;
  }
}
</style>