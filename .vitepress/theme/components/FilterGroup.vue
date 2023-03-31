<script setup>
const props = defineProps(['label', 'key', 'filters'])
</script>

<template>
  <div class="choice">
    <h5>{{ label }}</h5>

    <div class="form-check" v-for="(choiceOption, index) in filters">
      <input class="form-check-input" type="checkbox" value="" :id="choiceOption + index" v-model="choiceOption.checked">
      <label class="form-check-label" :for="choiceOption + index">
        <span class="badge rounded-pill" :style="{ 'background-color': choiceOption.color }">{{ choiceOption.label
        }}</span>
      </label>
    </div>
  </div>
</template>

<style scoped>
.choice {
  margin-bottom: 10px;
  padding-bottom: 10px;
  border-bottom: 1px solid #CCC
}

.choice:last-child {
  border-bottom: none;
}
</style>