---
title: Uninstall ECS Anywhere
description: >-
  A bash script that cleans up a host that was used as capacity for ECS Anywhere
image: cover.png
filterDimensions:
  - key: tool
    value: aws-cli
  - key: type
    value: script
---

  ## {{ $frontmatter.title }}

  Params; {{ $params }}

  The following script removes the components of ECS Anywhere from a host. After running
  this you can reinstall ECS Anywhere back onto the host cleanly.

  However, you should be
  aware that each time you cleanup the SSM registration key and reregister the host it will
  be a new SSM managed intance. Additionally, you may still need to use the SSM console or API to clean up old managed instances that you no longer wish to track.

<codefile filename='uninstall-ecs-anywhere.sh' language='shell'>
</codefile>
