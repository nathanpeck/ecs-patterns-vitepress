<script setup>
import { ref } from 'vue';
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
let className;
if (fileExists) {
  className = `language-${lang} line-numbers`
} else {
  className = `language-${lang} no-line-numbers`
}

function copy() {
  navigator.clipboard.writeText(content.value.textContent);
  const shiki = content.value.children[0]
  shiki.classList.add('copying')
  setTimeout(() => {
    shiki.classList.remove('copying')
  }, 300)
}

function downloadAsText(text) {
  var element = document.createElement('a');
  element.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(text));
  element.setAttribute('download', filename);
  element.style.display = 'none';
  document.body.appendChild(element);
  element.click();
  document.body.removeChild(element);
  const shiki = content.value.children[0]
  shiki.classList.add('copying')
  setTimeout(() => {
    shiki.classList.remove('copying')
  }, 300)
}

function download() {
  downloadAsText(content.value.textContent)
}
</script>

<template>
  <div class="codeBlockTopper clearfix">
    <span v-if="fileExists" class="badge bg-light text-dark">File: {{ filename }}</span>
    <span class="badge bg-light text-dark">Language: {{ lang }}</span>
    <button v-if="fileExists" type="button" class="download btn btn-dark float-end" @click="download">Download</button>
    <button type="button" class="copy btn btn-dark float-end" @click="copy" ref="copyButton">Copy</button>
  </div>
  <div :class="className" ref="content">
    <slot />
  </div>
</template>

<style>
.shiki {
  background-color: #2e3440ff;
  overflow: auto;
  overflow-wrap: break-word;
  padding-top: 1rem;
  padding-right: 1rem;
  padding-bottom: 1rem;
  margin-bottom: 3rem;
  white-space: pre-wrap;
  border-bottom-left-radius: 5px;
  border-bottom-right-radius: 5px;
}

.no-line-numbers code {
  padding-left: 1rem;
}

.codeBlockTopper {
  padding: .3em;
  color: white;
  line-height: 2.3em;
  padding-left: 1em;
  background-color: rgb(26, 30, 36);
  border-top-left-radius: 5px;
  border-top-right-radius: 5px;
}

.codeBlockTopper .badge {
  margin-right: .3em;
}

div[class^="language-"] {
  position: relative;
  max-width: 1000px;
}

.copy {
  margin-right: 10px;
  border-radius: 5px;
  border: 1px solid rgb(71, 80, 98);
}

.download {
  margin-right: 10px;
  border-radius: 5px;
  border: 1px solid rgb(71, 80, 98);
}

@-webkit-keyframes copying {
  0% {
    background-color: #777;
    opacity: 1;
  }

  100% {
    background-color: #2e3440ff;
  }
}

.copying {
  -webkit-animation-name: copying;
  -webkit-animation-duration: 200ms;
  -webkit-animation-iteration-count: 300ms;
  -webkit-animation-timing-function: ease-in;
}

.line-numbers code {
  counter-reset: step;
  counter-increment: step 0;
}

.line-numbers code .line::before {
  content: counter(step);
  counter-increment: step;
  width: 2rem;
  margin-right: 1.5rem;
  display: inline-block;
  text-align: right;
  color: rgba(115, 138, 148, .4)
}
</style>