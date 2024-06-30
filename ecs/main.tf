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
  associate_public_ip_address = false 

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
resource "aws_instance" "ec2_instance" {
  ami                    = "data.aws_ami.ecs_optimized.id"
  subnet_id              = var.privatesubnet[0]
  instance_type          = "t2.micro"
  iam_instance_profile   = aws_iam_instance_profile.ecs_instance_profile.name
  vpc_security_group_ids = [var.security_group_ids]
  ebs_optimized          = "false"
  source_dest_check      = "false"
  root_block_device {
    volume_type           = "gp2"
    volume_size           = "30"
    delete_on_termination = "true"
  }
}

resource "aws_autoscaling_group" "ecs" {
  launch_configuration = aws_launch_configuration.ecs.id
  min_size             = 1
  max_size             = 1
  desired_capacity     = 1
  vpc_zone_identifier  = var.privatesubnet
}

resource "aws_ecs_task_definition" "ecs_task" {
  depends_on = [var.nats_repo, aws_instance.ec2_instance]
  family                   = "my-ecs-task"
  execution_role_arn       = aws_iam_role.ecs_instance_role.arn
  network_mode             = "awsvpc" 
  requires_compatibilities = ["EC2"]

  container_definitions = jsonencode([
    {
      name      = "nodeapp"
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
  depends_on = [var.nats_repo, aws_instance.ec2_instance, aws_ecs_task_definition.ecs_task]
  name            = "my-ecs-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.ecs_task.arn
  desired_count   = 1                             
  launch_type     = "EC2"  

  deployment_controller {
    type = "ECS"
  }

  network_configuration {
    security_groups = [var.security_group_ids]
    subnets         = var.privatesubnet 
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = var.aws_lb_target_group_arn
    container_name   = "nodeapp"
    container_port   = 80
  }
}
