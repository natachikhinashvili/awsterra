# awsterra

## if u use mac - in ecs file use cpu_architecture        = "ARM64" and in launch template t4g.large
## otherwise  in ecs file use cpu_architecture        = "X86_64" and in launch template t3.large

# force delete secretsmanager aws secretsmanager delete-secret --secret-id "arn:aws:secretsmanager:us-east-1:...:secret:.../some-name" --force-delete-without-recovery