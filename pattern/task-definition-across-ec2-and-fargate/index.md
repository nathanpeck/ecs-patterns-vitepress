---
title: Task definition that works on both EC2 and AWS Fargate
description: >-
  How to make a task definition that can deploy either as a serverless
  application on AWS Fargate or as a conatiner on EC2 instance capacity
image: cover.png
filterDimensions:
  - key: tool
    value: cloudformation
  - key: type
    value: pattern
  - key: capacity
    value: ec2
  - key: capacity
    value: fargate
authors:
  - peckn
date: Apr 14, 2023
---

One of the convenient features of Amazon ECS is that it is agnostic when
it comes to capacity type. You can create an ECS task definition that deploys
to both AWS Fargate and Amazon EC2 instances at the same time.

This pattern shows the key parts of the task definition that make this possible.

<<< @/pattern/task-definition-across-ec2-and-fargate/files/task-definition.yml