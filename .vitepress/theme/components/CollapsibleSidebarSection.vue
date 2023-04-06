<script setup>
import { ref } from 'vue'
const { title } = defineProps(['title'])

const collapseMe = ref(null);

function headerClick() {
  // When the page is wide enough we never
  // collapse sidebar items
  if (document.body.clientWidth >= 900) {
    return;
  }
  collapseMe.value.classList.toggle('expanded');
}
</script>

<template>
  <div class="card collapseMe" @click="headerClick" ref="collapseMe">
    <div class="card-header">
      {{ title }}
      <svg data-v-198a53c3="" xmlns="http://www.w3.org/2000/svg" aria-hidden="true" focusable="false" viewBox="0 0 24 24"
        class="icon">
        <path
          d="M9,19c-0.3,0-0.5-0.1-0.7-0.3c-0.4-0.4-0.4-1,0-1.4l5.3-5.3L8.3,6.7c-0.4-0.4-0.4-1,0-1.4s1-0.4,1.4,0l6,6c0.4,0.4,0.4,1,0,1.4l-6,6C9.5,18.9,9.3,19,9,19z">
        </path>
      </svg>
    </div>
    <div class="card-body">
      <slot />
    </div>
  </div>
</template>

<style>
.collapseMe {
  margin-bottom: 20px;
}

.collapseMe .card-header svg {
  fill: var(--bs-emphasis-color)
}

.collapseMe .card-header svg {
  display: none;
}

@media screen and (max-width: 900px) {
  .expanded {
    clear: both;
  }

  .card.collapseMe:not(.expanded) {
    flex-grow: 0;
    width: auto;
    float: left;
    margin-right: 10px;
  }

  .collapseMe:not(.expanded) .card-body {
    display: none;
  }

  .collapseMe:not(.expanded) .card-header {
    font-size: 1em;
    padding: 8px;
  }

  .collapseMe:not(.expanded) .card-header svg {
    width: 16px;
    height: 16px;
    display: inline-block;
    vertical-align: middle;
  }

  /* When screen is small the header is alway
     clickable */
  .collapseMe .card-header {
    user-select: none;
    cursor: pointer;
  }

  .collapseMe.expanded .card-header svg {
    width: 16px;
    height: 16px;
    display: inline-block;
    vertical-align: middle;
    transform: rotate(90deg);
  }
}
</style>