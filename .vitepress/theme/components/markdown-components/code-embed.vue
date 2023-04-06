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
  <div class="codeBlockTopper">
    <div>
      <span v-if="fileExists" class="badge">File: {{ filename }}</span>
      <span class="badge">Language: {{ lang }}</span>
    </div>
    <div class="codeBlockTopperButtons">
      <button v-if="fileExists" type="button" class="download btn" @click="download">Download</button>
      <button type="button" class="copy btn" @click="copy" ref="copyButton">Copy</button>
    </div>
  </div>
  <div :class="className" ref="content">
    <slot />
  </div>
</template>

<style>
.shiki {
  background-color: var(--bs-tertiary-bg);
  border: 1px solid var(--bs-border-color);
  border-top: none;
  max-height: 1000px;
  overflow: auto;
  overflow-wrap: break-word;
  padding-top: 1rem;
  padding-right: 1rem;
  padding-bottom: 1rem;
  margin-bottom: 3rem;
  /**white-space: pre-wrap;**/
  border-bottom-left-radius: 5px;
  border-bottom-right-radius: 5px;
}

/* width */
.shiki::-webkit-scrollbar {
  width: 10px;
  height: 10px;
}

/* Track */
.shiki::-webkit-scrollbar-track {
  background: var(--bs-secondary-bg);
}

/* Handle */
.shiki::-webkit-scrollbar-thumb {
  background: var(--bs-tertiary-color);
}

/* Handle on hover */
.shiki::-webkit-scrollbar-thumb:hover {
  background: #555;
}

.shiki::-webkit-scrollbar-corner {
  background-color: var(--bs-secondary-bg);
}

.no-line-numbers code .line {
  margin-left: 1rem;
}

.codeBlockTopper {
  padding: .3em;
  color: white;
  line-height: 1.6em;
  padding-left: 1em;
  background-color: var(--bs-tertiary-bg);
  border: 1px solid var(--bs-border-color);
  border-bottom: none;
  border-top-left-radius: 5px;
  border-top-right-radius: 5px;
  max-width: 1000px;
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  align-items: center;
}

.codeBlockTopper .badge {
  margin-right: .3em;
  line-height: 1em;
  background-color: var(--bs-light-bg-subtle);
  border: 1px solid var(--bs-light-border-subtle);
  color: var(--bs-emphasis-color);
}

.codeBlockTopper .btn {
  padding: .4em;
  line-height: 1em;
  background-color: var(--bs-tertiary-bg);
  border: 1px solid var(--bs-light-border-subtle);
  color: var(--bs-emphasis-color);
}

div[class^="language-"] {
  position: relative;
  max-width: 1000px;
}

.copy {
  margin-left: 10px;
  border-radius: 5px;
  border: 1px solid rgb(71, 80, 98);
}

.download {
  border-radius: 5px;
  border: 1px solid rgb(71, 80, 98);
}

@-webkit-keyframes copying {
  0% {
    background-color: var(--bs-tertiary-bg);
    opacity: 1;
  }

  100% {
    background-color: var(--bs-primary-bg-subtle);
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

:root [data-bs-theme=dark] {
  --shiki-color-text: azure;
  --shiki-color-background: black;
  --shiki-token-constant: plum;
  --shiki-token-string: rgb(209, 185, 208);
  --shiki-token-comment: salmon;
  --shiki-token-keyword: powderblue;
  --shiki-token-parameter: seashell;
  --shiki-token-function: dodgerblue;
  --shiki-token-string-expression: burlywood;
  --shiki-token-punctuation: linen;
  --shiki-token-link: honeydew;
}

:root [data-bs-theme=light] {
  --shiki-color-text: black;
  --shiki-color-background: rgb(218, 247, 247);
  --shiki-token-constant: rgb(215, 75, 215);
  --shiki-token-string: rgb(72, 7, 70);
  --shiki-token-comment: rgb(229, 33, 11);
  --shiki-token-keyword: rgb(1, 140, 158);
  --shiki-token-parameter: rgb(243, 169, 117);
  --shiki-token-function: rgb(5, 123, 242);
  --shiki-token-string-expression: rgb(194, 125, 35);
  --shiki-token-punctuation: rgb(209, 132, 55);
  --shiki-token-link: rgb(149, 238, 149);
}
</style>