import fs from 'node:fs'
import yaml from 'js-yaml'

export default {
  watch: ['./data/authors.yml'],
  load(watchedFiles) {
    return yaml.load(fs.readFileSync('./data/authors.yml', 'utf-8'))
  }
}