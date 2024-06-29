resource "aws_db_instance" "main" {
  identifier              = "main-rds-instance"
  allocated_storage       = 20
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = "db.t2.micro"
  db_name                    = "mydatabase"
  username                = "admin"
  password                = "password123"
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
