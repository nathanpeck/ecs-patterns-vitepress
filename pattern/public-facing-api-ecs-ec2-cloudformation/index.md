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
---

Sometimes you want to create a public facing service, but you want stricter control over the networking of the service. This pattern is suitable for many of the same use cases of the public facing website pattern, but it is especially used in the following cases:

- An API which is public facing but needs an extra layer of security hardening by not even having a public IP address that an attacker could send a request directly to.
- An API service which needs to be massively horizontally scalable while not being constrained by number of IP addresses available.
- A web or API service which initiates outbound connections but to the public you want those connections to originate from a specific and limited set of IP addresses that can be whitelisted.

At a high level the architecture looks like this:

  <diagram filename='diagram.png'></diagram>

  Everything is deployed in an Amazon Virtual Private Cloud (VPC) which has two subnets:

- Public subnet: Has an attached internet gateway to allow resources launched in that subnet to accept connections from the internet, and initiate connections to the internet. Resources in this subnet have public IP addresses.
- Private subnet: For internal resources. Instances in this subnet have no direct internet access, and only have private IP addresses that are internal to the VPC, not directly accessible by the public.

The public facing subnet hosts a couple resources:

- Public facing load balancer: Accepts inbound connections on specific ports, and forwards acceptable traffic to resources inside the private subnet.
- NAT gateway: A networking bridge to allow resources inside the private subnet to initiate outbound communications to the internet, while not allowing inbound connections.

The private subnet is used to run your application containers. The EC2 instances hosting the containers do not have a public IP address, only a private IP address internal to the VPC. As a result if your application initiates an outbound connection the connection gets routed through the NAT gateway in the public subnet. Additionally, there is no way for any traffic to directly reach your container. Instead all inbound connections must go to the load balancer which will pick and choose whether to pass the inbound connection on to the protected container inside the private VPC subnet.

<<< @/pattern/public-facing-api-ecs-ec2-cloudformation/files/private-cluster.yml

<<< @/pattern/public-facing-api-ecs-ec2-cloudformation/files/public-service.yml
