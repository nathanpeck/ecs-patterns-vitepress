---
title: Serverless public facing API hosted on AWS Fargate
description: >-
  A serverless, containerized public facing API in a private network, managed by EC2, hosted on AWS Fargate
image: cover.png
filterDimensions:
  - key: tool
    value: cloudformation
  - key: app
    value: api
  - key: capacity
    value: fargate
  - key: type
    value: pattern
---

## {{ $frontmatter.title }}

{{ $frontmatter.description }}

  Sometimes you want to create a public facing service, but you want stricter control over the networking of the service. This pattern is suitable for many of the same use cases of the public facing website pattern, but it is especially used in the following cases:

- An API which is public facing but needs an extra layer of security hardening by not even having a public IP address that an attacker could send a request directly to.
- An API service which needs to be massively horizontally scalable while not being constrained by number of IP addresses available.
- A web or API service which initiates outbound connections but to the public you want those connections to originate from a specific and limited set of IP addresses that can be whitelisted.

At a high level the architecture looks like this:

  <diagram filename='diagram.svg'></diagram>

  Everything is deployed in an Amazon Virtual Private Cloud (VPC) which has two subnets:

- Public subnet: Has an attached internet gateway to allow resources launched in that subnet to accept connections from the internet, and initiate connections to the internet. Resources in this subnet have public IP addresses.
- Private subnet: For internal resources. Instances in this subnet have no direct internet access, and only have private IP addresses that are internal to the VPC, not directly accessible by the public.

The public facing subnet hosts a couple resources:

- Public facing load balancer: Accepts inbound connections on specific ports, and forwards acceptable traffic to resources inside the private subnet.
- NAT gateway: A networking bridge to allow resources inside the private subnet to initiate outbound communications to the internet, while not allowing inbound connections.

<<< @/pattern/public-facing-api-ecs-fargate-cloudformation/files/private-cluster.yml

<<< @/pattern/public-facing-api-ecs-fargate-cloudformation/files/public-service.yml
