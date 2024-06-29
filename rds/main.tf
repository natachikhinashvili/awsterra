resource "aws_db_instance" "main" {
  identifier              = "main-rds-instance"
  allocated_storage       = 20
  engine                  = "mysql"
  engine_version          = "8.0.35"  
  instance_class          = "db.t3.micro" 
  db_name                 = var.db_name
  username                = var.username
  password                = var.password
  parameter_group_name    = "default.mysql8.0"
  db_subnet_group_name    = var.subnetgroup
  vpc_security_group_ids  = var.securitygroup
  skip_final_snapshot     = true
}

output "db_instance_endpoint" {
  value = aws_db_instance.main.endpoint
}

output "db_instance_id" {
  value = aws_db_instance.main.id
}
