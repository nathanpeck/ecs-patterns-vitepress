---
title: Public facing website hosted on EC2 instances
description: >-
  A containerized website, hosted as a public facing service, managed by EC2, hosted on EC2 capacity.
image: cover.png
filterDimensions:
  - key: tool
    value: cloudformation
  - key: app
    value: website
  - key: capacity
    value: ec2
  - key: type
    value: pattern
authors:
  - peckn
---

![](./files/diagram.png)

A public facing service is one of the most common architecture patterns for deploying containers on AWS. It is well suited for:

- A static HTML website, perhaps hosted by NGINX or Apache
- A dynamically generated web app, perhaps served by a Node.js process
- An API service intended for the public to access
- A public facing endpoint designed to receive push notifications, perhaps from Amazon SNS (Simple Notification Service)
- An edge service which needs to make outbound connections to other services on the internet

<<< @/pattern/public-facing-web-ecs-ec2-cloudformation/files/public-cluster.yml

<<< @/pattern/public-facing-web-ecs-ec2-cloudformation/files/public-service.yml
