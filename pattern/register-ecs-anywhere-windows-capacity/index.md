---
title: Register ECS Anywhere Windows Capacity
description: >-
  Command line scripts for registering external Windows instances with an ECS Cluster
image: cover.png
filterDimensions:
  - key: tool
    value: aws-cli
  - key: type
    value: script
  - key: capacity
    value: anywhere
---

## {{ $frontmatter.title }}

The easiest way to register external capacity with an ECS cluster is to use the Elastic Container Service web console, as it will automatically create an activation key and code, and prepopulate the commands with the right activation key for you. However if you wish to automate the registration process you can use the following commands as a template:

```sh
REGION="desired AWS region here"
ACTIVATION_ID="SSM managed instance activation id here"
ACTIVATION_CODE="SSM manage instance activation code here"
CLUSTER="ecs cluster name here"

Invoke-RestMethod -URI "https://amazon-ecs-agent.s3.amazonaws.com/ecs-anywhere-install.ps1" -OutFile "ecs-anywhere-install.ps1"; .\ecs-anywhere-install.ps1 -Region $REGION -Cluster $CLUSTER -ActivationID $ACTIVATION_ID -ActivationCode $ACTIVATION_CODE
```

The referenced install script which is downloaded from S3 is also embedded here for your review. This script handles the installation of Docker, the AWS Systems Manager agent, and the Elastic Container Service Agent:

<<< @/pattern/register-ecs-anywhere-windows-capacity/files/ecs-anywhere-install.ps1