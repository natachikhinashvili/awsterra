output "security_group_id" {
  value = aws_security_group.ecs_security_group.id
}

output "rds_security_group_id" {
  value = aws_security_group.rds.id
}

output "rds_security_group_name" {
  value = aws_security_group.rds.name
}


output "alb_security_group" {
  value = aws_security_group.load_balancer.id
}