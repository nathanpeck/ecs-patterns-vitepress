---
title: Use CDK to mount an EFS filesystem to an ECS task
description: >-
  CDK app showing how to mount an Elastic File System to a path inside of a container.
filterDimensions:
  - key: tool
    value: cdk
  - key: type
    value: pattern
authors:
 - peckn
date: April 4, 2023
---

#### About

Although it is considered best practice to deploy stateless containers, there are times when it is necessary to have durable filesystem storage attached to a container. This pattern
demonstrates how to write an AWS Cloud Development Kit application that deploys an Elastic File System, hosted in a VPC. It then launches a container in AWS Fargate, using Elastic Container Service to orchestrate attaching the Elastic File System to the container on the given path.

#### Python Cloud Development Kit Application

<<< @/pattern/cdk-mount-efs-filesystem-ecs-fargate-task/files/app.py

#### Setup

Install Cloud Development Kit by [following the prerequisites in the docs](https://docs.aws.amazon.com/cdk/v2/guide/work-with.html#work-with-prerequisites).

Ensure that you have Python 3 installed and then run the following commands:

```sh
python -m ensurepip --upgrade
python -m pip install --upgrade pip
python -m pip install --upgrade virtualenv
mkdir  cdk-efs-python
cdk-efs-python
cdk init app --language python
source .venv/bin/activate
python -m pip install -r requirements.txt
```

Download the contents of the `app.py` above and overwrite the `app.py` that was
created by `cdk init`.

#### Usage

Use the following commands to interact with your CDK application

```sh
cdk diff
cdk synth
cdk deploy
cdk destroy
```