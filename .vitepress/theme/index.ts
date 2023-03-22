// // @ts-ignore
import DefaultTheme from 'vitepress/theme'
import Layout from './Layout.vue'
import './style.css'

import Diagram from './components/markdown-components/diagram.vue'
import Youtube from './components/markdown-components/youtube.vue'

import { createPinia } from 'pinia'
const pinia = createPinia()

export default {
  /*...DefaultTheme,*/
  Layout,
  enhanceApp({ app, router, siteData }) {
    // ...
    app.use(pinia)

    app.component('diagram', Diagram)
    app.component('youtube', Youtube)
  }
}