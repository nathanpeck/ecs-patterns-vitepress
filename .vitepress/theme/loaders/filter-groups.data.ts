import fs from 'node:fs'
import yaml from 'js-yaml'

export default {
  watch: ['./data/filter-groups.yml'],
  load(watchedFiles) {
    return yaml.load(fs.readFileSync('./data/filter-groups.yml', 'utf-8'))
  }
}