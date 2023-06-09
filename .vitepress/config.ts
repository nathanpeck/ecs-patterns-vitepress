import { defineConfig } from 'vitepress'
import { snippetPlugin } from './theme/plugins/snippet'
import { svgPlugin } from './theme/plugins/svg'
import defaultFence from './theme/plugins/default_fence'
import { createWriteStream } from 'node:fs'
import { writeFile, readFile } from 'node:fs/promises'
import { resolve } from 'node:path'
import { SitemapStream } from 'sitemap'
import { BUNDLED_LANGUAGES } from 'shiki'
import yaml from 'js-yaml'
import { convert } from 'html-to-text';

// Patch an issue where it doesn't recognize
// Dockerfiles as Dockerfiles because there is no alias
const DOCKER_LANG = BUNDLED_LANGUAGES.find((lang) => {
  return lang.id == 'docker';
})
if (DOCKER_LANG) {
  DOCKER_LANG.aliases = ['dockerfile']
}

// Load in Terraform language
const TerraformGrammar = require('./theme/langs/Terraform.json')
const Terraform = {
  id: 'terraform',
  scopeName: 'source.terraform',
  grammar: TerraformGrammar,
  aliases: ['terraform', 'tf']
}

// Load the CloudWatch Query Language
// For more see: https://code.amazon.com/packages/LogsReactComponent/blobs/mainline/--/src/components/logs-insights/components/pschorrql-editor/editor-config/pschorrql-language-definition.ts
const CloudWatchQueryGrammar = require('./theme/langs/CloudWatchQuery.json')
const CloudWatchQuery = {
  id: 'cloudwatch',
  scopeName: 'text.query',
  grammar: CloudWatchQueryGrammar,
  aliases: ['query', 'cloudwatch']
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
const textForPage = {}

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "ECS Patterns",
  description: "A list of ECS patterns",
  base: '/pattern/',
  cleanUrls: true,
  srcExclude: ['**/README.md', '**/TODO.md'],
  rewrites: {
    'pattern/:patternName/index.md': ':patternName.md',
  },
  head: [
    ['link', { rel: 'preload stylesheet', href: 'https://use.fontawesome.com/releases/v5.0.13/css/all.css', as: 'style' }],
    ['link', { rel: 'preload stylesheet', href: 'https://prod.assets.shortbread.aws.dev/shortbread.css', as: 'style' }],

    // This script must be injected into the head of the document
    // to solve the "flash" problem of sites that have dark mode.
    // Without it the initial load will flash white for a second
    // until the body JS catches up and turns on dark mode
    [
      'script',
      {},
      `
      var query = window.matchMedia("(prefers-color-scheme: dark)");
      var themePreference = localStorage.getItem("theme");

      var active = query.matches;

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
    ],

    // This intercepts all clicks and avoids the Vitepress router
    // hijack when possible.
    [
      'script',
      {},
      `
      // Add a listener that avoids the Vitepress Router if there is
      // a link attribute
      window.addEventListener(
        'click',
        (e) => {
          const link = e.target.closest('a');
          if (!link) {
            return
          }

          if (link.getAttribute('hijack') == 'false') {
            e.stopImmediatePropagation();
            window.location = link.getAttribute('href')
            return true
          }
        },
        { capture: true }
      )
      `
    ]
  ],

  // Extend the Markdown parser with extra features
  markdown: {
    theme: 'css-variables',
    languages: [Terraform, CloudWatchQuery],
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
      md.use(svgPlugin, process.cwd())
    }
  },

  // Extract a list of all the links in the site
  transformHtml: (_, id, { pageData, content }) => {
    const text = convert(content, {
      baseElements: {
        selectors: ['.content']
      }
    });

    textForPage[pageData.relativePath] = text;

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
        relativePath: pageData.relativePath,
        url: cleanUrl
      });
    }
  },

  // Because blog is hosted using a different system we want
  // any cross links between patterns and blog to be ignored
  // otherwise the VitePress build will call them out as dead links
  ignoreDeadLinks: [
    '/blog/'
  ],

  // Write out some artifacts like a sitemap and index.json file
  buildEnd: async ({ outDir }) => {

    console.log("Generating sitemap.xml");

    // Write out the sitemap.xml
    const sitemap = new SitemapStream({
      hostname: 'https://d2rkbl8jpwujc2.cloudfront.net/'
    })
    const writeStream = createWriteStream(resolve(outDir, 'sitemap.xml'))
    sitemap.pipe(writeStream)
    links.forEach((link) => sitemap.write(link))
    sitemap.end()
    await new Promise((r) => writeStream.on('finish', r))

    // Now write out an index file of page data to be used for
    // a search index.
    console.log("Generating search index JSON");

    const filters = yaml.load(await readFile('./data/filters.yml', 'utf-8'))

    var filtersByKeyValue = {}
    filters.forEach(function (filter) {
      filtersByKeyValue[`${filter.key}:${filter.value}`] = filter;
    })

    const authors = yaml.load(await readFile('./data/authors.yml', 'utf-8'))

    var authorsByKey = {}
    authors.forEach(function (author) {
      authorsByKey[author.id] = author;
    })

    const formattedPages = pages.map((page) => {
      let tags = [];

      if (page.filterDimensions) {
        tags = page.filterDimensions.map((dimension) => {
          return filtersByKeyValue[`${dimension.key}:${dimension.value}`].label
        })
      }

      let foundAuthor = {
        name: 'System',
        image: 'https://ecsland.jldeen.dev/images/ship.svg'
      };

      if (page.authors) {
        foundAuthor = authorsByKey[page.authors[0]]
      }

      return {
        title: page.title,
        image: 'https://ecsland.jldeen.dev/images/featured-pattern.svg',
        author: foundAuthor.name,
        authorimage: foundAuthor.image,
        authors: page.authors,
        url: `/${page.url}`,
        tags: tags,
        summary: page.description,
        content: textForPage[page.relativePath],
        date: page.date
      }
    })

    const json = JSON.stringify(formattedPages);
    await writeFile(resolve(outDir, 'patterns.json'), json, 'utf-8')
  }
})
