#!/usr/bin/env python3
import os
from constructs import Construct
import aws_cdk as cdk
from aws_cdk import (
    Stack,
    Duration,
    aws_ec2 as ec2,
    aws_ecs as ecs,
    aws_elasticloadbalancingv2 as elb2,
    aws_efs as efs,
    aws_iam as iam,
)

class CdkEfsPythonStack(Stack):
    def __init__(
        self,
        scope: Construct,
        id: str,
        **kwargs,
    ) -> None:
        super().__init__(scope, id, **kwargs)

        vpc = ec2.Vpc(
            self, "MyVpc",
            max_azs=2
        )

        self.file_system = efs.FileSystem(
            self,
            "EfsFileSystem",
            vpc=vpc,
            lifecycle_policy=efs.LifecyclePolicy.AFTER_7_DAYS,  # files are not transitioned to infrequent access (IA) storage by default
            performance_mode=efs.PerformanceMode.GENERAL_PURPOSE,  # default
            out_of_infrequent_access_policy=efs.OutOfInfrequentAccessPolicy.AFTER_1_ACCESS,
        )

        self.load_balancer = elb2.ApplicationLoadBalancer(
            self,
            "ServiceLB",
            http2_enabled=True,
            vpc=vpc,
            internet_facing=True,
            load_balancer_name="ecs-lb",
        )

        self.cluster = ecs.Cluster(
            self,
            "Cluster",
            container_insights=True,
            vpc=vpc,
            enable_fargate_capacity_providers=True,
        )

        capacity = [
            ecs.CapacityProviderStrategy(
                capacity_provider="FARGATE",
                weight=100,
            ),
        ]

        task_def = ecs.FargateTaskDefinition(
            self,
            "TaskDefinition",
            cpu=256,
            memory_limit_mib=512,
            runtime_platform=ecs.RuntimePlatform(
                cpu_architecture=ecs.CpuArchitecture.ARM64,
                operating_system_family=ecs.OperatingSystemFamily.LINUX,
            ),
        )

        efs_volume_name = "efs-volume"

        task_def.add_volume(
            name=efs_volume_name,
            efs_volume_configuration=ecs.EfsVolumeConfiguration(
                file_system_id=self.file_system.file_system_id,
            ),
        )

        container = task_def.add_container(
            "Container",
            image=ecs.ContainerImage.from_registry("public.ecr.aws/ubuntu/nginx:1.18-20.04_beta"),
            port_mappings=[ecs.PortMapping(container_port=80, host_port=None)],
        )
        container.add_mount_points(
            ecs.MountPoint(
                source_volume=efs_volume_name,
                container_path="/var/www/html",
                read_only=False,
            )
        )

        task_def.add_to_task_role_policy(
            iam.PolicyStatement(
                actions=[
                    "elasticfilesystem:ClientRootAccess",
                    "elasticfilesystem:ClientWrite",
                    "elasticfilesystem:ClientMount",
                    "elasticfilesystem:DescribeMountTargets",
                ],
                resources=[
                    f"arn:aws:elasticfilesystem:{Stack.of(self).region}:{Stack.of(self).account}:file-system/{self.file_system.file_system_id}"
                ],
            )
        )
        task_def.add_to_task_role_policy(
            iam.PolicyStatement(
                actions=["ec2:DescribeAvailabilityZones"],
                resources=["*"],
            )
        )

        self.service = ecs.FargateService(
            self,
            "Service",
            task_definition=task_def,
            cluster=self.cluster,
            desired_count=None,
            max_healthy_percent=200,
            min_healthy_percent=50,
            health_check_grace_period=Duration.seconds(100),
            capacity_provider_strategies=capacity,
            enable_ecs_managed_tags=True,
        )

        self.listener = self.load_balancer.add_listener(
            "HttpListener",
            port=80,
            protocol=elb2.ApplicationProtocol.HTTP,
        )

        self.targets = self.listener.add_targets(
            "HttpTG",
            targets=[self.service],
            port=80,
            protocol=elb2.ApplicationProtocol.HTTP,
            deregistration_delay=Duration.seconds(10),
            slow_start=Duration.seconds(30),
            health_check=elb2.HealthCheck(enabled=True, path="/health"),
        )

app = cdk.App()
CdkEfsPythonStack(
    app,
    "CdkEfsPythonStack",
    env=cdk.Environment(
      account=os.environ["CDK_DEFAULT_ACCOUNT"],
      region=os.environ["CDK_DEFAULT_REGION"])
)

app.synth()
