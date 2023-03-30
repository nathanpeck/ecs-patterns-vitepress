---
title: Public facing API hosted on EC2 instances
description: >-
  A containerized public facing API in a private network, managed by EC2, hosted on EC2 capacity.
image: cover.png
filterDimensions:
  - key: tool
    value: cloudformation
  - key: app
    value: api
  - key: capacity
    value: ec2
  - key: type
    value: pattern
authors:
  - peckn
date: March 30, 2023
---

This pattern demonstrates how to host an API service, or other critical internal service which needs access to both public and private resources. This pattern allows you to host your containerized service in the private portion of your VPC network, but still expose it to the public via a load balancer ingress in the public portion of your VPC network.

This pattern is suitable many use cases:

- An API which is public facing but needs an extra layer of security hardening by not even having a public IP address that an attacker could send a request directly to.
- A web facing service which needs to be massively horizontally scalable while not being constrained by number of public IP addresses available.
- A web or API service which initiates outbound connections to another service on the internet. You want those outbound connections to all originate from a specific and limited set of IP addresses that can be whitelisted by recipients of the traffic.

At a high level the architecture looks like this:

<img src="./files/diagram.png" />

Everything is deployed in an Amazon Virtual Private Cloud (VPC) which has two subnets:

- __Public subnet__: Has an attached internet gateway to allow resources launched in that subnet to accept connections from the internet, and initiate connections to the internet. Resources in this subnet have public IP addresses.
- __Private subnet__: For internal resources. Instances in this subnet have no direct internet access, and only have private IP addresses that are internal to the VPC, not directly accessible by the public.

The public facing subnet hosts a couple resources:

- __Public facing load balancer__: Accepts inbound connections on specific ports, and forwards acceptable traffic to resources inside the private subnet.
- __NAT gateway__: A networking bridge to allow resources inside the private subnet to initiate outbound communications to the internet, while not allowing inbound connections.

The private subnet is used to run your application containers. The EC2 instances hosting the containers do not have a public IP address, only a private IP address internal to the VPC. As a result if your application initiates an outbound connection the connection gets routed through the NAT gateway in the public subnet. Additionally, there is no way for any traffic to directly reach your container. Instead all inbound connections must go to the load balancer which will pick and choose whether to pass the inbound connection on to the protected container inside the private VPC subnet.

#### Deploy the network and Elastic Container Service (ECS) cluster

First download the following CloudFormation template:

<<< @/pattern/public-facing-api-ecs-ec2-cloudformation/files/private-cluster.yml

Parameters to note are:

- `DesiredCapacity` - How many EC2 instances to launch
- `MaxSize` - The maximum number of EC2 instance to scale up to
- `ECSAMI` - This will be automatically set to the latest ECS optimized Amazon Linux machine image, but you can override it if you want
- `InstanceType` - The EC2 instance size to launch

Additionally you may wish to customize `Mappings.SubnetConfig`. These CIDR values control how big the IP space is in the VPC. If you plan to launch many EC2 instances and many containers on those EC2 instances then consider increasing the size of those CIDR ranges.

This template can be deployed with the following AWS CLI command:

```sh
aws cloudformation deploy \
   --stack-name development \
   --template-file private-cluster.yml \
   --capabilities CAPABILITY_IAM \
   --parameter-overrides DesiredCapacity=3 MaxSize=6
```

Alternatively you can open the AWS CloudFormation web console and click "Create Stack"

#### Deploy the containerized service

Once the VPC network and cluster has been launched, it is time to download and launch the following template:

<<< @/pattern/public-facing-api-ecs-ec2-cloudformation/files/public-service.yml

Parameters to note are:

- `StackName` - The name of the previous stack that was launched
- `ServiceName` - What you want to name your deployed service
- `ImageUrl` - The URI of a Docker image to launch. You can leave it as the default `nginx` image if don't yet have a container image to deploy
- `ContainerPort` - What port number the application inside the docker container is binding to
- `ContainerCpu` - How much CPU to give the container. 1024 CPU is one vCPU core
- `ContainerMemory` - How many MB's of memory to give the container
- `DesiredCount` - How many copies of the container to launch. Traffic will be evenly distributed across all copies.
- `Role` - If your containerized application wants to use the AWS SDK to access other AWS services it will need an IAM role. This settings allows you to pass the ARN of an IAM role for the container to use.

Deploy the template with the following AWS CLI command:

```sh
aws cloudformation deploy \
   --stack-name development \
   --template-file private-cluster.yml \
   --capabilities CAPABILITY_IAM \
   --parameter-overrides StackName=development
```

As before you can also choose to use the AWS CloudFormation web console to launch this CloudFormation stack.

#### Next Steps

- This stack does not deploy an automatic scaling for the containerized service. You should [add scaling to your service](/pattern/scale-ecs-service-cloudformation).
- This example stack currently deploys a statically sized EC2 Autoscaling Group (ASG). You can manually scale up the ASG as needed to add more EC2 capacity for hosting more containers, but you may prefer to instead use an ECS Capacity Provider to have ECS automatically manage the ASG size on your behalf.
- Alternatively, you may prefer to not manage EC2 capacity at all. In that case consider using the [AWS Fargate version of this stack](/pattern/public-facing-api-ecs-fargate-cloudformation), which launches your container on serverless capacity.
