---
title: Basic container app with custom image build
description: >-
  A Cloud Development Kit app showing how to automatically
  build and upload local code as a container image when
  launching your application in AWS Fargate
image: cover.png
filterDimensions:
  - key: tool
    value: cdk
  - key: type
    value: pattern
  - key: capacity
    value: fargate
authors:
  - peckn
---

#### Usage

- Install AWS CDK: https://docs.aws.amazon.com/cdk/v2/guide/hello_world.html
- Run `cdk deploy`

<<< @/pattern/basic-cdk-service-custom-image/files/index.ts
