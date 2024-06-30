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

data "aws_ssm_parameter" "ecs_node_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}
resource "aws_iam_role_policy_attachment" "ecs_instance_role" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = "ecs_instance_profile"
  role = aws_iam_role.ecs_instance_role.name
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "my-cluster"
}

resource "aws_autoscaling_group" "failure_analysis_ecs_asg" {
  name                = "asg"
  vpc_zone_identifier = var.privatesubnet

  desired_capacity          = 2
  min_size                  = 1
  max_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "EC2"

  launch_template {
    id = aws_launch_template.engine.id
  }
}

resource "aws_launch_template" "engine" {
  name          = "alma"
  image_id      = data.aws_ssm_parameter.ecs_node_ami.value
  instance_type = "t2.micro"
  user_data     = base64encode("#!/bin/bash\necho ECS_CLUSTER=my-cluster >> /etc/ecs/ecs.config")

  vpc_security_group_ids = [var.security_group_ids]
  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }
}

resource "aws_ecs_capacity_provider" "provider" {
  name = "provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.failure_analysis_ecs_asg.arn
    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 100
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 10
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_capacity_providers" {
  cluster_name       = aws_ecs_cluster.ecs_cluster.name
  capacity_providers = [aws_ecs_capacity_provider.provider.name]
}


resource "aws_ecs_task_definition" "task_definition" {
  family = "worker"
  network_mode             = "awsvpc"

  container_definitions = jsonencode([
    {
      essential   = true
      memory      = 2012
      name        = "worker"
      cpu       = 1056
      image       = "${var.repository_url}:latest"
      portMappings = [
        {
          containerPort = 3000
          hostPort      = 3000
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "worker" {
  name            = "worker"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn 
  desired_count   = 1

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.provider.name
    weight            = 1
  }

  network_configuration {
    security_groups = [var.security_group_ids]
    subnets         = var.privatesubnet 
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = var.aws_lb_target_group_arn
    container_name   = "worker"
    container_port   = 3000
  }
}