<script setup>
import { defineProps } from 'vue';
const { headers } = defineProps(['headers'])
</script>

<template>
  <ul class="outline-list">
    <li v-for="header in headers">
      <a :href='header.link'>{{ header.title }}</a>
    </li>
  </ul>
</template>

<style>
ul.outline-list {
  list-style-type: none;
  padding-left: 0px;
  margin-bottom: 0px;
}

ul.outline-list li {
  list-style-type: none;
}
</style>