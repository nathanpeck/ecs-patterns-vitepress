import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "ECS Patterns",
  description: "A list of ECS patterns",
  cleanUrls: true,
  rewrites: {
    'pattern/:patternName/index.md': 'pattern/:patternName.md'
  }
})
