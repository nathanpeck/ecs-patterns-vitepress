---
title: Scale ECS service based on CPU consumption
description: >-
  CloudFormation for automatically scaling an ECS service up and down based on CPU usage
image: cover.png
filterDimensions:
  - key: tool
    value: cloudformation
  - key: type
    value: pattern
authors:
  - peckn
---

Autoscaling is very important to making sure that your services stay online when traffic increases unexpectedly. In both EC2 and AWS Fargate one way to ensure your service autoscales is to increase and decrease the number of copies of your application container that are running in the cluster.

Autoscaling works like this:

![](./files/diagram.png)

The following template automatically sets up CloudWatch alarms, autoscaling policies, and attaches them to an ECS service.

<<< @/pattern/scale-ecs-service-cloudformation/files/scale-service-by-cpu.yml
