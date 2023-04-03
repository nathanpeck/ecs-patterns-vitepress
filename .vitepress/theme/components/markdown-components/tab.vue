<script setup>
import { inject } from 'vue'

const { label } = defineProps(['label'])
const activeTabLabel = inject('activeTabLabel')
</script>

<template>
  <slot v-if="label == activeTabLabel" />
</template>