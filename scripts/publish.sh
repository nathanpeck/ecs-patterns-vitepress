aws s3 sync .vitepress/dist/ s3://ecs-patterns/ --delete
aws cloudfront create-invalidation --distribution-id EUL1QI0MAG73C --paths '/*'