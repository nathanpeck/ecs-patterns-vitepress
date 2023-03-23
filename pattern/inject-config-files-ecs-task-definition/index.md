---
title: Inject configuration files in an Elastic Container Service (ECS) task definition
description: >-
  How to add custom config files to your container at runtime, by using a command
  override in the ECS task definition
image: cover.png
filterDimensions:
  - key: tool
    value: cloudformation
  - key: type
    value: pattern
---

## {{ $frontmatter.title }}

{{ $frontmatter.description }}

The following snippet is an AWS CloudFormation template for an ECS task definition.

It launches an NGINX reverse proxy server, directly from Amazon Elastic Container Registry Public. This default container does not do anything except show a simple
"welcome to NGINX" message. However, we can use a command to generate the custom NGINX configuration at runtime, prior to launching the container. Because this command runs inside the container as it launches we can even use custom environment variables
from the task definition.

<<< @/pattern/inject-config-files-ecs-task-definition/files/task-definition.yml
