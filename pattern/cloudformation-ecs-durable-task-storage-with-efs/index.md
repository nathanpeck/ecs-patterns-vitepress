---
title: Add durable storage to an ECS task, with Amazon Elastic File System
description: >-
  CloudFormation template showing how to mount an Elastic File System to a path inside of a container.
filterDimensions:
  - key: tool
    value: cloudformation
  - key: type
    value: pattern
  - key: feature
    value: efs
  - key: feature
    value: exec
authors:
 - peckn
date: April 4, 2023
---

#### About

In this example you will deploy two NGINX web server tasks that have a shared durable web content folder stored on an Elastic File System. You will also use Amazon ECS Exec to access the containers and verify that data is synced across tasks and persisted across task restarts.

#### Setup your environment

- Ensure that the [AWS CLI is installed and configured](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- Install the [Session Manager plugin for the AWS CLI](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html)

#### Deploy the CloudFormation

<<< @/pattern/cloudformation-ecs-durable-task-storage-with-efs/files/ecs-mount-efs-storage.yml

The stack requires the following three parameters:

- `VpcId` - A virtual private cloud ID. This can be the default VPC that comes with your AWS account. Example value: `vpc-79508710`
- `SubnetOne` - A public subnet inside of that VPC. Example value: `subnet-b4676dfe`
- `SubnetTwo` - Another public subnet isnide of that VPC. Example value: `subnet-c71ebfae`

::: tip
When using the CloudFormation web console it will suggest appropriate parameter values in the drop down on each parameter field, if you are not certain what to enter for each parameter.
:::

Deploy the CloudFormation template by using the web console, or with the following AWS CLI command. (Substitute your own VPC details.)

```sh
aws cloudformation deploy \
  --template-file ecs-mount-efs-storage.yml \
  --stack-name test-stack \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides VpcId=vpc-79508710 SubnetOne=subnet-b4676dfe SubnetTwo=subnet-c71ebfae
```

#### Test out Elastic File System

First open an ECS Exec session to each running container using a command like this:

```sh
aws ecs execute-command \
  --cluster <insert cluster name here> \
  --task <insert task ID here> \
  --container nginx \
  --interactive \
  --command "/bin/sh"
```

Run the above command twice in two different terminals, and with two different task ID's so that you have one session open to each task.

In each session type:

```sh
cd /usr/share/nginx/html
ls
```

This will verify that both directories are empty.

Try running the following command in both containers:

```sh
curl localhost:80
```

You will see a `403 Forbidden` error from NGINX because there is no content in the shared HTML directory.

Run the following command in only one of the open sessions:

```sh
echo "Hello world" > index.html
```

In the other container's session run `ls` to see that an `index.html` file has appeared.

Run the `curl` command again in both containers:

```sh
curl localhost:80
```

Observe that both NGINX web servers are seeing the same web content over the Elastic File System.

#### Test data durability

Terminate both tasks using the Amazon ECS web console, or API.

When the ECS service starts a replacement task, open a new ECS Exec session to
the replacement task.

Run the following commands again in this replacement task:

```sh
cd /usr/share/nginx/html
ls
curl localhost:80
```

You will see that the `index.html` file you wrote to the Elastic File System in the
previous instance of the container has been persisted and is still
there in the new replacement task.

#### See Also

- [Tutorial on setting up EFS on ECS](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/tutorial-efs-volumes.html)