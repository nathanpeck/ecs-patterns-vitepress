<script setup>
import { storeToRefs } from "pinia"
import { useContentStore } from '../stores/content'
import { ref, watch, onBeforeMount } from "vue";

const contentStore = useContentStore();
const { themeSetting } = storeToRefs(contentStore);

const darkModeToggle = ref(false);

// During init set the toggle based on the initial value
// from the local storage setting
if (themeSetting.value == 'dark') {
  darkModeToggle.value = true;
}

// Watch the toggle box and when it changes
// update the theme setting
watch(darkModeToggle, () => {
  if (darkModeToggle.value) {
    themeSetting.value = 'dark'
  } else {
    themeSetting.value = 'light'
  }
})

// Respond to changes to the theme setting by setting the
// Bootstrap theme attribute on the body of the document.
onBeforeMount(() => {
  document.body.setAttribute('data-bs-theme', themeSetting.value)
})

watch(themeSetting, () => {
  document.body.setAttribute('data-bs-theme', themeSetting.value)
})

/*
 * Note that this dark mode switch also uses an injected <head> script which
 * sets the body attribute on the initial page load before any content is
 * rendered. This script prevents an initial flash of white. You can find the
 * script in config.ts
 */
</script>

<template>
  <div class="dark-mode-switch d-flex" style="margin-top: .30rem;">
    <input type="checkbox" class="checkbox" id="btnSwitch" v-model="darkModeToggle" />
    <label class="label" for="btnSwitch" aria-label="Toggle light/dark mode">
      <i class="fas fa-moon" alt="dark mode"></i>
      <i class="fas fa-sun" alt="light mode"></i>
      <div class="ball"></div>
    </label>
  </div>
</template>

<style scoped>
.label {
  background-color: #111;
  border-radius: 50px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 5px;
  position: relative;
  height: 26px;
  width: 50px;
  transform: scale(1);
}

.label .ball {
  background-color: #fff;
  border-radius: 50%;
  position: absolute;
  top: 2px;
  left: 2px;
  height: 22px;
  width: 22px;
  transform: translateX(0px);
  transition: transform 0.2s linear;
}

.checkbox {
  opacity: 0;
  position: absolute;
}

.checkbox:checked+.label .ball {
  transform: translateX(24px);
}


.fa-moon {
  color: #f1c40f;
}

.fa-sun {
  color: #f39c12;
}
</style>