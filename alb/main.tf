resource "aws_lb" "nodeapp_lb" {
  name               = "nodeapp-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group_id]
  subnets            = var.subnets
}

resource "aws_lb_target_group" "nodeapp_tg" {
  name     = "nodeapp-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  target_type = "ip"

  health_check {
    interval            = 30
    path                = "/"
    timeout             = 5
    unhealthy_threshold = 2
    healthy_threshold   = 2
    matcher             = "200-499"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.nodeapp_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nodeapp_tg.arn
  }
}