import { defineConfig } from 'vitepress'
import { highlight } from './theme/plugins/highlight'
import { snippetPlugin } from './theme/plugins/snippet'
import process from 'node:process'
import defaultFence from './theme/plugins/default_fence'

const extractLang = (info: string) => {
  return info
    .trim()
    .replace(/:(no-)?line-numbers({| |$).*/, '')
    .replace(/(-vue|{| ).*$/, '')
    .replace(/^vue-html$/, 'template')
}

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "ECS Patterns",
  description: "A list of ECS patterns",
  cleanUrls: true,
  rewrites: {
    'pattern/:patternName/index.md': 'pattern/:patternName.md'
  },
  head: [
    //['link', { rel: 'stylesheet', href: 'https://unpkg.com/tailwindcss@^1.0/dist/tailwind.min.css' }]
  ],
  markdown: {
    config: (md) => {
      // Fully override the fence rules with my own customized version
      md.renderer.rules.fence = (...args) => {

        const [tokens, idx] = args
        const token = tokens[idx]
        // remove title from info
        token.info = token.info.replace(/\[.*\]/, '')

        const lang = extractLang(token.info)
        const rawCode = defaultFence(...args)
        return `<div class="language-${lang}${/ active( |$)/.test(token.info) ? ' active' : ''
          }"><button type="button" class="download"></button><button type="button" class="copy"></button>${rawCode}</div>`
      }

      // Now restore the plugins that I want to use
      md.use(snippetPlugin, process.cwd())
    }
  }
})
