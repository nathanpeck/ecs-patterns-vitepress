<script setup>
import { ref, onMounted } from 'vue';
const { lang, filename } = defineProps(['lang', 'filename'])

let fileExists = false;
if (filename !== 'undefined') {
  fileExists = true;
}

// Placeholders for elements
// On component DOM mount the values are populated.
const content = ref(null);
const copyButton = ref(null);

// Shiki code highlighter class
const className = `language-${lang}`;

function copy() {
  navigator.clipboard.writeText(content.value.textContent);
  copyButton.value.innerText = "Copied"
}

function downloadAsText(text) {
  var element = document.createElement('a');
  element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(text));
  element.setAttribute('download', filename);
  element.style.display = 'none';
  document.body.appendChild(element);
  element.click();
  document.body.removeChild(element);
}

function download() {
  downloadAsText(content.value.textContent)
}
</script>

<template>
  <button v-if="fileExists" type="button" class="download btn btn-dark" @click="download">Download</button>
  <button type="button" class="copy btn btn-dark" @click="copy" ref="copyButton">Copy</button>
  <span v-if="fileExists">
    <b>File:</b> {{ filename }}
  </span>
  <div :class="className" ref="content">
    <slot />
  </div>
</template>

<style>
.shiki {
  background-color: #2e3440ff;
  overflow: auto;
  overflow-wrap: break-word;
  padding: 2rem;
  margin-top: .5rem;
  margin-bottom: 3rem;
  white-space: pre-wrap;
  border-radius: 5px;
}

div[class^="language-"] {
  position: relative;
  max-width: 1000px;
}

.copy {
  margin-right: 10px;
  border-radius: 5px;
}

.download {
  margin-right: 10px;
  border-radius: 5px;
}
</style>
