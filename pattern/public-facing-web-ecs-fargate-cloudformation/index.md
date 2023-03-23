---
title: Serverless public facing website hosted on AWS Fargate
description: >-
  A containerized website, hosted as a public facing service, managed by EC2, hosted on serverless AWS Fargate capacity
image: cover.png
filterDimensions:
  - key: tool
    value: cloudformation
  - key: app
    value: website
  - key: capacity
    value: fargate
  - key: type
    value: pattern
---
## {{ $frontmatter.title }}

{{ $frontmatter.description }}

  <diagram filename='diagram.svg'></diagram>

  A public facing service is one of the most common architecture patterns for deploying containers on AWS. It is well suited for:

  - A static HTML website, perhaps hosted by NGINX or Apache
  - A dynamically generated web app, perhaps served by a Node.js process
  - An API service intended for the public to access
  - A public facing endpoint designed to receive push notifications, perhaps from Amazon SNS (Simple Notification Service)
  - An edge service which needs to make outbound connections to other services on the internet

<<< @/pattern/public-facing-web-ecs-fargate-cloudformation/files/public-cluster.yml

<<< @/pattern/public-facing-web-ecs-fargate-cloudformation/files/public-service.yml
