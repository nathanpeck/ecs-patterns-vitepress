import { defineConfig } from 'vitepress'
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

const filenameRE = /\[(.*?)\]/;

const extractFilename = (info: string) => {
  const match = info.match(filenameRE);

  if (match) {
    return match[1]
  }
  else {
    null
  }
};

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "ECS Patterns",
  description: "A list of ECS patterns",
  cleanUrls: true,
  srcExclude: ['**/README.md', '**/TODO.md'],
  rewrites: {
    'pattern/:patternName/index.md': 'pattern/:patternName.md',
    'team/': 'team'
  },
  head: [
    ['link', { rel: 'stylesheet', href: 'https://use.fontawesome.com/releases/v5.0.13/css/all.css' }],

    // This script must be injected into the head of the document
    // to solve the "flash" problem of sites that have dark mode.
    // Without it the initial load will flash white for a second
    // until the body JS catches up and turns on dark mode
    [
      'script',
      {},
      `
      const query = window.matchMedia("(prefers-color-scheme: dark)");
      const themePreference = localStorage.getItem("theme");

      let active = query.matches;

      if (themePreference === "dark") {
        active = true;
      }

      if (themePreference === "light") {
        active = false;
      }

      if (active) {
        document.documentElement.setAttribute('data-bs-theme', 'dark')
      } else {
        document.documentElement.setAttribute('data-bs-theme', 'light')
      }
      `
    ]
  ],
  markdown: {
    theme: 'css-variables',
    config: (md) => {
      // Fully override the fence rules with my own customized version
      md.renderer.rules.fence = (...args) => {
        const [tokens, idx] = args
        const token = tokens[idx]

        const filename = extractFilename(token.info);

        token.info = token.info.replace(/\[.*\]/, '')
        const lang = extractLang(token.info)

        const rawCode = defaultFence(...args)
        return `<code-embed lang='${lang}' filename='${filename}'>${rawCode}</code-embed>`
      }

      // Now restore the plugins that I want to use
      md.use(snippetPlugin, process.cwd())
    }
  }
})
