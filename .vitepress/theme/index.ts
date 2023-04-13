// // @ts-ignore
import Layout from './Layout.vue'
import './style.css'

import Code from './components/markdown-components/code-embed.vue'
import Youtube from './components/markdown-components/youtube.vue'
import Tabs from './components/markdown-components/tabs.vue'
import Tab from './components/markdown-components/tab.vue'

import { createPinia } from 'pinia'
const pinia = createPinia()

export default {
  Layout,
  enhanceApp({ app, router, siteData }) {
    // A client side data store for shared data
    app.use(pinia)

    // Custom HTML components used to enhance and style
    // things embedded in the markdown.
    app.component('code-embed', Code)
    app.component('youtube', Youtube)
    app.component('tabs', Tabs)
    app.component('tab', Tab)
  }
}