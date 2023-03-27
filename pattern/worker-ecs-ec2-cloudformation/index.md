---
title: Internal worker or background service hosted on EC2 instances
description: >-
  A containerized worker or internal service, in a private network, managed by EC2, hosted on EC2 capacity.
image: cover.png
filterDimensions:
  - key: tool
    value: cloudformation
  - key: app
    value: worker
  - key: capacity
    value: ec2
  - key: type
    value: pattern
---

A fully private service is generally used for important internal business services that need to be protected from direct access by the public:

- Cache service such as Redis
- Internal API that provides a thin wrapper around a database
- Billing, password and authentication, or other similar service that has personally identifying information.
- Internal background worker service

A private service’s architecture looks like this:

![](./files/diagram.png)

Everything is deployed in an Amazon Virtual Private Cloud (VPC) which has two subnets:

- Public subnet: Has an attached internet gateway to allow resources launched in that subnet to accept connections from the internet, and initiate connections to the internet. Resources in this subnet have public IP addresses.
- Private subnet: For internal resources. Instances in this subnet have no direct internet access, and only have private IP addresses that are internal to the VPC, not directly accessible by the public.

The public facing subnet hosts a couple resources:

- Public facing load balancer: Accepts inbound connections on specific ports, and forwards acceptable traffic to resources inside the private subnet.
- NAT gateway: A networking bridge to allow resources inside the private subnet to initiate outbound communications to the internet, while not allowing inbound connections.

The private subnet is used to run your application containers. The EC2 instances hosting the containers do not have a public IP address, only a private IP address internal to the VPC. As a result if your application initiates an outbound connection the connection gets routed through the NAT gateway in the public subnet. Additionally, there is no way for any traffic to directly reach your container. Instead all inbound connections must go to the load balancer which will pick and choose whether to pass the inbound connection on to the protected container inside the private VPC subnet.

<<< @/pattern/worker-ecs-ec2-cloudformation/files/private-cluster.yml

<<< @/pattern/worker-ecs-ec2-cloudformation/files/private-service.yml
