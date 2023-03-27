---
title: Register ECS Anywhere Linux Capacity
description: >-
  Command line scripts for registering external Linux instances with an ECS Cluster
image: cover.png
filterDimensions:
  - key: tool
    value: aws-cli
  - key: type
    value: script
  - key: capacity
    value: anywhere
authors:
  - peckn
---

The easiest way to register external capacity with an ECS cluster is to use the Elastic Container Service web console, as it will automatically create an activation key and code, and prepopulate the commands with the right activation key for you. However if you wish to automate the registration process you can use the following commands as a template:

```sh
REGION="desired AWS region here"
ACTIVATION_ID="SSM managed instance activation id here"
ACTIVATION_CODE="SSM manage instance activation code here"
CLUSTER="ecs cluster name here"

curl --proto "https" -o "/tmp/ecs-anywhere-install.sh" "https://amazon-ecs-agent.s3.amazonaws.com/ecs-anywhere-install-latest.sh" && bash /tmp/ecs-anywhere-install.sh --region $REGION --cluster $CLUSTER --activation-id $ACTIVATION_ID --activation-code $ACTIVATION_CODE
```

The referenced install script which is downloaded from S3 is also embedded here for your review. This script handles the installation of Docker, the AWS Systems Manager agent, and the Elastic Container Service Agent:

<<< @/pattern/register-ecs-anywhere-linux-capacity/files/ecs-anywhere-install-latest.sh
