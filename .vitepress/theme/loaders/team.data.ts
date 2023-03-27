import fs from 'node:fs'
import yaml from 'js-yaml'

export default {
  watch: ['./data/team.yml'],
  load(watchedFiles) {
    return yaml.load(fs.readFileSync('./data/team.yml', 'utf-8'))
  }
}