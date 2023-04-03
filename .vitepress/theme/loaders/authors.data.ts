import fs from 'node:fs'
import yaml from 'js-yaml'

export default {
  watch: ['**/authors.yml'],
  load(watchedFiles) {
    return yaml.load(fs.readFileSync('./data/authors.yml', 'utf-8'))
  }
}