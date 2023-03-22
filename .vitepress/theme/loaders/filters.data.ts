import fs from 'node:fs'
import yaml from 'js-yaml'

export default {
  watch: ['./data/filters.yml'],
  load(watchedFiles) {
    return yaml.load(fs.readFileSync('./data/filters.yml', 'utf-8'))
  }
}