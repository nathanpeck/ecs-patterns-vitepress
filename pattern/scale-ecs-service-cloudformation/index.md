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
date: March 30, 2023
---

Autoscaling is very important to making sure that your services stay online when traffic increases unexpectedly. In both EC2 and AWS Fargate one way to ensure your service autoscales is to increase and decrease the number of copies of your application container that are running in the cluster.

Autoscaling works like this:

![](./files/diagram.png)

#### CloudFormation

The following template automatically sets up CloudWatch alarms, autoscaling policies, and attaches them to an ECS service.

<<< @/pattern/scale-ecs-service-cloudformation/files/scale-service-by-cpu.yml

#### Usage

- `EnvironmentName` - The name of a base CloudFormation stack that contains the ECS cluster resource. This stack is intended to be one of the other patterns such as the [serverless public facing task stack](/pattern/public-facing-api-ecs-fargate-cloudformation)
- `ServiceName` - The name of the ECS service to scale

You can deploy the template via the AWS CloudFormation web console, or by running an AWS CLI command:

```sh
aws cloudformation deploy \
   --stack-name scale-my-service-name \
   --template-file scale-service-by-cpu.yml \
   --parameter-overrides EnvironmentName=development ServiceName=my-web-service
```
