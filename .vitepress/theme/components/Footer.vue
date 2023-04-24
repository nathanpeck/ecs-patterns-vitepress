<script setup>
import { onMounted } from 'vue';

let script;
let shortBread;

function loadShortbread() {
  // Must load in shortbread first
  script = document.createElement('script');
  script.type = 'text/javascript';
  script.src = 'https://prod.assets.shortbread.aws.dev/shortbread.js';
  document.head.appendChild(script);

  // Prepare the shortbread instance once the script loads
  script.onload = () => {
    shortBread = window.AWSCShortbread({
      domain: window.location.hostname
    })
  }
}

function openShortbread() {
  shortBread.customizeCookies();
}

// Preload in background after page ready, for more responsive
// action on click.
onMounted(() => {
  loadShortbread();
})
</script>

<template>
  <div class="footer">
    <a href="https://aws.amazon.com/privacy/">Privacy</a> -
    <a href="https://aws.amazon.com/terms/">Site Terms</a> -
    <a href="#" @click="openShortbread">Cookie Preferences</a> -
    © Copyright 2023 Amazon.com, Inc. or its affiliates. All rights reserved.
  </div>
</template>

<style scoped>
.footer {
  width: 100%;
  background-color: var(--bs-body-bg);
  color: var(--bs-body-color);
  padding: 20px;
  border-top: 3px solid var(--bs-border-color);
}

.footer a {
  color: rgb(255, 146, 45);
}
</style>