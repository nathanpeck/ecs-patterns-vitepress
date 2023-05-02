---
title: Deploy Jupyter notebook container with Amazon ECS
description: >-
  How to use Amazon ECS and CloudFormation to run a Jupyter notebook container for training machine learning models
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
date: May 2 2023
---

[Jupyter Notebook](https://jupyter.org/) is a web-based interactive computing platform. It is popular for machine learning and as an IDE for developing in multiple programming languages.

[AWS Inferentia](https://aws.amazon.com/machine-learning/inferentia/) accelerators are designed by AWS to deliver high performance at the lowest cost for your deep learning (DL) inference applications. When training your models use [AWS Trainium](https://aws.amazon.com/machine-learning/trainium/) Instances, which are optimized for model training.

[AWS Neuron](https://aws.amazon.com/machine-learning/neuron/) is the SDK which runs your model on the underlying hardware of AWS Inferentia or AWS Trainium.

This pattern will show how to build and deploy a containerized version of Jupyter notebook, with the AWS Neuron SDK for machine learning with AWS Inferentia and AWS Trainium hardware acceleration.

#### Setup

This pattern is designed to build on top of the previous pattern for [deploying a machine learning cluster on Amazon ECS](/machine-learning-inference-aws-inferentia-cloudformation). First, follow the instructions in that tutorial to deploy a cluster of AWS Inferentia instances, setup a parent stack used to deploy further resources, and verify connectivity via AWS Neuron.

__Dependencies__:
* [Docker](https://www.docker.com/) or OCI compatible container builder
* [Amazon ECR Credential Helper](https://github.com/awslabs/amazon-ecr-credential-helper)
* [AWS SAM CLI](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html)

#### Build a Jupyter notebook container

In order to build a Jupyter notebook container we will start with a prebuild image from the AWS Deep Learning Container collection, then install Jupyter Lab on top of it:

```Dockerfile
FROM 763104351884.dkr.ecr.us-east-2.amazonaws.com/huggingface-pytorch-inference-neuron:1.10.2-transformers4.20.1-neuron-py37-sdk1.19.1-ubuntu18.04
RUN pip install jupyterlab
CMD jupyter-lab
```

Create the `Dockerfile` and then build the custom image locally:

```shell
docker build -t jupyter-notebook .
```

Now we need to create an Amazon Elastic Container Registry:

```shell
aws ecr create-repository --repository-name jupyter-notebook
```

You should get a response similar to this:

```json
{
  "repository": {
      "repositoryUri": "209640446841.dkr.ecr.us-east-2.amazonaws.com/jupyter-notebook",
      "imageScanningConfiguration": {
          "scanOnPush": false
      },
      "encryptionConfiguration": {
          "encryptionType": "AES256"
      },
      "registryId": "209640446841",
      "imageTagMutability": "MUTABLE",
      "repositoryArn": "arn:aws:ecr:us-east-2:209640446841:repository/jupyter-notebook",
      "repositoryName": "jupyter-notebook",
      "createdAt": 1683047667.0
  }
}
```

Copy the `repositoryUri` as this is how you will interact with the repository:

```shell
docker tag jupyter-notebook 209640446841.dkr.ecr.us-east-2.amazonaws.com/jupyter-notebook:latest
docker push 209640446841.dkr.ecr.us-east-2.amazonaws.com/jupyter-notebook:latest
```

::: info
If you get a 401 unauthorized error then make sure you have installed the [Amazon ECR credential helper](https://github.com/awslabs/amazon-ecr-credential-helper). It will automatically use your current AWS credentials to authenticate with the repository on the fly.
:::

#### Define the notebook task

The following CloudFormation template deploys a Jupyter Notebook task under Amazon ECS orchestration:

<<< @/pattern/jupyter-notebook-inferencing-container-cloudformation/files/jupyter-notebook.yml

Some things to note:

- You will need to customize the `Image` inside the `ContainerDefinitions` to match the container image URI that you just uploaded to Amazon ECR.
- The template creates a `AWS::SecretsManager::Secret` resource as the secret token used to protect the Jupyter notebook from unauthorized access. You will see this token passed in as a `Secret` in the task definition body.

#### Deploy the notebook

Add the Jupyer Notebook to the parent stack by adding the following lines to the `Resources` section of the YAML:

```yml
  JupyterNotebook:
    Type: AWS::Serverless::Application
    Properties:
      Location: jupyter-notebook.yml
      Parameters:
        VpcId: !Ref VpcId
        SubnetIds: !Join [',', !Ref SubnetIds]
        ClusterName: !GetAtt BaseStack.Outputs.ClusterName
        ECSTaskExecutionRole: !GetAtt BaseStack.Outputs.ECSTaskExecutionRole
        CapacityProvider: !GetAtt BaseStack.Outputs.CapacityProvider
```

You can also remove the `neuron-test` application from the `parent.yml` stack if you no longer need it.

Now you can use `sam` to deploy the parent stack with a command like this one. As before you will need to supply your own VPC and subnet ID's:

```shell
sam deploy \
  --template-file parent.yml \
  --stack-name jupyter \
  --resolve-s3 \
  --capabilities CAPABILITY_IAM \
  --parameter-overrides VpcId=vpc-79508710 SubnetIds=subnet-b4676dfe,subnet-c71ebfae
```

#### Allow inbound traffic from your IP address

The network security group that protects the Jupyter notebook from attackers is currently rejecting all inbound traffic. In order to get secure access to the notebook we will open it up to traffic from your IP address only.

1. Determine your local IP address by typing "what is my IP" into your favorite search engine

#### Get the secret token

We need to read the Jupyter notebook secret token out of AWS Secrets Manager in order to access the notebook.

#### Next Steps

- If you would like data that you store inside of your Jupyter notebook to survive ECS task restarts, then consider using the [tutorial on attaching durable storage to an ECS task](cloudformation-ecs-durable-task-storage-with-efs) and use a similar technique to mount an Elastic File System to the Jupyter Task