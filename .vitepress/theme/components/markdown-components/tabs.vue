<script setup>
import { useSlots, ref, provide } from 'vue';

const slots = useSlots();
let tabs = slots.default().filter(child => child.type.__name == 'tab')

const activeTabLabel = ref('')
activeTabLabel.value = tabs[0].props.label;
provide('activeTabLabel', activeTabLabel);

function selectTab(tab) {
  activeTabLabel.value = tab.props.label;
}
</script>

<template>
  <div>
    <div class="tabs">
      <ul>
        <li v-for="tab in tabs" :class="{ 'is-active': activeTabLabel == tab.props.label }" @click="selectTab(tab)">
          <a :href="tab.href" rel="nofollow">{{ tab.props.label }}</a>
        </li>
      </ul>
    </div>

    <div class="tabs-details">
      <slot />
    </div>
  </div>
</template>

<style>
.tabs ul {
  display: flex;
  flex: 1;
  margin: 0 0 1rem;
  padding: 0 !important;
  justify-content: space-between;
  justify-items: stretch;
}

.tabs ul li {
  cursor: pointer;
  border-bottom: 2px solid var(--bs-border-color-translucent);
  text-align: center;
  font-weight: 500;
  width: 100%;
  line-height: 2em;
  list-style: none !important;
  padding-bottom: 5px;
  padding-top: 5px;
}

.tabs ul li:hover {
  border-bottom: 2px solid gray;
  text-align: center;
  width: 100%;
  line-height: 2em;
  list-style: none !important;
}

.tabs .is-active {
  border-bottom: 2px solid rgb(246, 106, 49);
  background-color: rgba(0, 0, 0, .05);
}

.tabs .is-active:hover {
  border-bottom: 2px solid rgb(246, 106, 49);
}
</style>