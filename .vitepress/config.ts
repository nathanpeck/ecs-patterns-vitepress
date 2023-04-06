import { defineConfig } from 'vitepress'
import { snippetPlugin } from './theme/plugins/snippet'
import defaultFence from './theme/plugins/default_fence'
import { createWriteStream } from 'node:fs'
import { writeFile } from 'node:fs/promises'
import { resolve } from 'node:path'
import { SitemapStream } from 'sitemap'
import { BUNDLED_LANGUAGES } from 'shiki'

// Patch an issue where it doesn't recognize
// Dockerfiles as Dockerfiles because there is no alias
const DOCKER_LANG = BUNDLED_LANGUAGES.find((lang) => {
  return lang.id == 'docker';
})
if (DOCKER_LANG) {
  DOCKER_LANG.aliases = ['dockerfile']
}

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

const links: Object[] = []
const pages: Object[] = []

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
    //['link', { rel: 'preload', as: 'font', href: 'https://use.fontawesome.com/releases/v5.0.13/webfonts/fa-solid-900.woff2' }],
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
    //languages: ,
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
  },

  // Extract a list of all the links in the site
  transformHtml: (_, id, { pageData }) => {
    if (!/[\\/]404\.html$/.test(id)) {
      const cleanUrl = pageData.relativePath.replace(/((^|\/)index)?\.md$/, '$2')

      links.push({
        // you might need to change this if not using clean urls mode
        url: cleanUrl,
        lastmod: pageData.lastUpdated
      })

      pages.push({
        title: pageData.title,
        description: pageData.description,
        filterDimensions: pageData.frontmatter.filterDimensions,
        authors: pageData.frontmatter.authors,
        date: pageData.frontmatter.date,
        url: cleanUrl
      });
    }
  },

  // Write out some artifacts like a sitemap and index.json file
  buildEnd: async ({ outDir }) => {
    // Write out the sitemap.xml
    const sitemap = new SitemapStream({
      hostname: 'https://d2rkbl8jpwujc2.cloudfront.net/'
    })
    const writeStream = createWriteStream(resolve(outDir, 'sitemap.xml'))
    sitemap.pipe(writeStream)
    links.forEach((link) => sitemap.write(link))
    sitemap.end()
    await new Promise((r) => writeStream.on('finish', r))

    // Now write out an index file of page data
    const json = JSON.stringify(pages);
    await writeFile(resolve(outDir, 'index.json'), json, 'utf-8')
  }
})
