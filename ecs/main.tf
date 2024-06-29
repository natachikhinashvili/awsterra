resource "aws_iam_role" "ecs_instance_role" {
  name = "ecs_instance_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecs_instance_profile"
  role = aws_iam_role.ecs_instance_role.name
}

resource "aws_ecs_cluster" "main" {
  name = "main_ecs_cluster"
}

resource "aws_launch_configuration" "ecs" {
  name                        = "ecs_launch_configuration"
  image_id                    = data.aws_ami.ecs_optimized.id
  instance_type               = "t2.micro"
  iam_instance_profile        = aws_iam_instance_profile.ecs_instance_profile.name
  security_groups             = [var.security_group_ids]
  associate_public_ip_address = true

  user_data = <<EOF
#!/bin/bash
echo ECS_CLUSTER=${aws_ecs_cluster.main.name} >> /etc/ecs/ecs.config
EOF
}

data "aws_ami" "ecs_optimized" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  owners = ["amazon"]
}

resource "aws_autoscaling_group" "ecs" {
  launch_configuration = aws_launch_configuration.ecs.id
  min_size             = 1
  max_size             = 1
  desired_capacity     = 1
  vpc_zone_identifier  = var.subnet
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "my-ecs-task"
  execution_role_arn       = aws_iam_role.ecs_instance_role.arn
  network_mode             = "bridge"  
  requires_compatibilities = ["EC2"]  

  container_definitions = jsonencode([
    {
      name      = "my-container"
      image     = "${var.repository_url}:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
}
resource "aws_ecs_service" "ecs_service" {
  name            = "my-ecs-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.ecs_task.arn
  desired_count   = 1

  deployment_controller {
    type = "ECS"
  }

  network_configuration {
    security_groups = [var.security_group_ids]
    subnets         = var.subnet
    assign_public_ip = true
  }
}
