---
title: Delete an ECS task definition using AWS CLI
description: >-
  A bash script for deleting ECS task definitions using the AWS CLI
image: cover.png
filterDimensions:
  - key: tool
    value: aws-cli
  - key: type
    value: script
---

#### Installation

Download the script below and use `chmod` to make it executable:

```
chmod +x delete-tasks.sh
```

Script contents:

<<< @/pattern/ecs-delete-task-definition/files/delete-tasks.sh

#### Usage

Modify the following variables to use the script:

- `TASKNAME` - The task definition family to delete from. Use `aws ecs list-task-definitions` to list task definitions if you are unsure.
- `START` - The revision number to start deleting from
- `END` - The revision number to stop deleting at

Note that task definitions are 1 based, not zero based, so to delete the first 1000 task definition revisions set START=1 and END=1000


#### See also

- [AWS Containers Blog about task definition delete](https://aws.amazon.com/blogs/containers/announcing-amazon-ecs-task-definition-deletion/)
- [Instructions for how to delete task definitions in the AWS console](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/delete-task-definition-v2.html)

<!--Watch a video of how to delete task definitions in the console:

<youtube id='aNehm5WKaAM'></youtube>-->
