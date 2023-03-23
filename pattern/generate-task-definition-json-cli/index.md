---
title: Create new Elastic Container Service (ECS) task definition revision
description: >-
  A bash script example showing how to create a new revision of an ECS task definition, with variables for image URI, and other values.
image: cover.png
filterDimensions:
  - key: tool
    value: aws-cli
  - key: type
    value: script
---

## {{ $frontmatter.title }}

{{ $frontmatter.description }}

#### Installation

Download the script below and use `chmod` to make it executable:

```
chmod +x script.sh
```

Script contents:

<<< @/pattern/generate-task-definition-json-cli/files/script.sh

#### Usage

This script demonstrates the use of a [here document](https://en.wikipedia.org/wiki/Here_document) to embed a task definition template in a bash script. You can interpolate variable values from the bash script into the task definition template, and then pass the entire JSON structure to the `aws ecs create-task-definition` CLI command using the `--cli-input-json` flag.