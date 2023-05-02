---
title: Machine learning inference acceleration with AWS Inferentia
description: >-
  How to use Amazon ECS and CloudFormation to run
  machine learning inference tasks on AWS Inferentia accelerator powered instances
image: cover.png
filterDimensions:
  - key: tool
    value: cloudformation
  - key: type
    value: pattern
  - key: app
    value: machine-learning
authors:
  - peckn
date: May 1 2023
---

[AWS Inferentia](https://aws.amazon.com/machine-learning/inferentia/) accelerators are designed by AWS to deliver high performance at the lowest cost for your deep learning (DL) inference applications. When training your models use [AWS Trainium](https://aws.amazon.com/machine-learning/trainium/) Instances, which are optimized for model training.

[AWS Neuron](https://aws.amazon.com/machine-learning/neuron/) is the SDK which runs your model on the underlying hardware of AWS Inferentia or AWS Trainium.

Amazon Elastic Container Service supports running AWS Neuron applications on instances that have AWS Inferentia accelerator capabilities. This pattern shows how to use AWS CloudFormation to provision a cluster that has AWS Inferentia accelerators that will power an inference workload running under Amazon ECS orchestration.

#### Dependencies

This pattern uses AWS SAM CLI for deploying CloudFormation stacks on your account. You should follow the appropriate steps for [installing SAM CLI](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html).

#### Inferentia Cluster

First we setup an AWS cluster that is configured to launch AWS Inferentia instances.

<<< @/pattern/machine-learning-inference-aws-inferentia-cloudformation/files/inferentia-cluster.yml

The ECS cluster in this template uses a special ECS optimized AMI for Inferentia. You can get the latest AMI ID programmatically with this command:

```shell
aws ssm get-parameter --name /aws/service/ecs/optimized-ami/amazon-linux-2/inf/recommended/image_id
```

The template will automatically grab the latest AMI ID.

This template accepts the following parameters:

- `InstanceType` - The size of AWS Inferentia instance to launch.
- `VpcId` - The ID of an Amazon VPC. Can be the default VPC on your AWS account
- `SubnetIds` - Comma separated list of subnet ID's from the VPC. These can be public subnets from your default VPC.

#### AWS Neuron task

Next we need to deploy an AWS Neuron container as an ECS task that will be placed into the cluster.

<<< @/pattern/machine-learning-inference-aws-inferentia-cloudformation/files/neuron-test.yml

This template is running a container from the collection of [AWS Deep Learning Container](https://github.com/aws/deep-learning-containers/blob/master/available_images.md). The container comes with AWS Neuron SDK and tooling preinstalled.

The ECS Task will run the `neuron-ls` test command inside of the container. This will verify that the SDK inside of the container is able to connect to the underlying hardware acceleration.

Take note of the `LinuxParameters.Devices` section of the container definition. This is how the Neuron device is provided to the containerized application.

#### Deploy everything

The following nested parent stack deploys both the Inferentia Cluster and the AWS Neuron service in one step:

<<< @/pattern/machine-learning-inference-aws-inferentia-cloudformation/files/parent.yml

Run a command like the following to deploy the nested stack:

```shell
sam deploy \
  --template-file parent.yml \
  --stack-name inferentia-environment \
  --resolve-s3 \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides VpcId=vpc-79508710 SubnetIds=subnet-b4676dfe,subnet-c71ebfae
```

#### Verify that Neuron is available

The `neuron-service` task definition is currently just running
a test command to verify that it can connect to the Neuron device
provided by AWS Inferentia.

Use the Amazon ECS console to check the logs tab for the running task, and you should see something like this:

```txt
+--------+--------+--------+---------+
| NEURON | NEURON | NEURON |   PCI   |
| DEVICE |  CORES | MEMORY |   BDF   |
+--------+--------+--------+---------+
|    0   |    2   |  32 GB | 00:1f.0 |
+--------+--------+--------+---------+
```

This verified that AWS Neuron was able to connect to the underlying acceleration hardware provided by the AWS Inferentia instance.

#### Next Steps

- In order to experiment with AWS Neuron fully you probably want to [run a Juypter Notebook via Amazon ECS](/jupyter-notebook-inferencing-container-cloudformation) so that you can have an interactive development environment.