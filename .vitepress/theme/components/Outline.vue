<script setup>
import { getHeaders } from './composables/outline';
import { onContentUpdated } from 'vitepress'
import { ref } from 'vue';

const headers = ref([]);

onContentUpdated(() => {
  headers.value = getHeaders();
})
</script>

<template>
  <div class="card outline">
    <div class="card-header">
      Table of Contents
    </div>
    <div class="card-body">
      <ul class="outline-list">
        <li v-for="header in headers">
          <a :href='header.link'>{{ header.title }}</a>
        </li>
      </ul>
    </div>
  </div>
</template>

<style>
.outline {
  margin-bottom: 20px;
}

ul.outline-list {
  list-style-type: none;
  padding-left: 0px;
}

ul.outline-list li {
  list-style-type: none;
}
</style>