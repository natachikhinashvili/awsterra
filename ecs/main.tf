data "aws_ssm_parameter" "ecs_optimized_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended"
}

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

resource "aws_iam_role_policy_attachment" "ecs_attach" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_instance_role_policy" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecr_policy_attachment" {
  role       = aws_iam_role.ecs_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  name = var.instanceprofilename
  role = aws_iam_role.ecs_instance_role.name
}


resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.cluster_name
}


resource "aws_launch_template" "ecs_lt" {
  name_prefix   = var.template_name
  image_id      = jsondecode(data.aws_ssm_parameter.ecs_optimized_ami.value)["image_id"]
  instance_type = "t3.micro"

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 30
      volume_type = "gp2"
    }
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.security_group_ids]
  }

  user_data = base64encode("#!/bin/bash\n echo ECS_CLUSTER=nats-cluster >> /etc/ecs/ecs.config")
}


resource "aws_autoscaling_group" "ecs_asg" {
  vpc_zone_identifier = var.privatesubnet
  desired_capacity    = 1
  max_size            = 1
  min_size            = 1

  launch_template {
    id      = aws_launch_template.ecs_lt.id
    version = "$Latest"
  }
}

resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
  name = var.capacityprovidername

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs_asg.arn

    managed_scaling {
      maximum_scaling_step_size = 5
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 60
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_capacity_providers" {
  cluster_name       = aws_ecs_cluster.ecs_cluster.name
  capacity_providers = [aws_ecs_capacity_provider.ecs_capacity_provider.name]
  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
  }
}

resource "aws_ecs_task_definition" "task_definition" {
  family                   = var.container_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  task_role_arn            = "arn:aws:iam::850286438394:role/ecsTaskExecutionRole"
  execution_role_arn       = "arn:aws:iam::850286438394:role/ecsTaskExecutionRole"
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      essential = true
      name      = var.container_name
      cpu       = 256
      memory    = 512
      image     = "850286438394.dkr.ecr.eu-central-1.amazonaws.com/creed:latest"
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
  name            = var.service_name
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = 1

  network_configuration {
    subnets         = var.privatesubnet
    security_groups = [var.security_group_ids]
  }

  force_new_deployment = true
  placement_constraints {
    type = "distinctInstance"
  }

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ecs_capacity_provider.name
    base              = 1
    weight            = 100
  }

  load_balancer {
    target_group_arn = var.aws_lb_target_group_arn
    container_name   = var.container_name
    container_port   = 80
  }

  depends_on = [aws_autoscaling_group.ecs_asg]
}
