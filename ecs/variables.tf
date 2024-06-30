variable "security_group_ids" {
  description = "List of security group IDs"
  type        = string
}

variable "subnet" {
  type        = list(string)
}

variable "vpc_id" {
  type        = string
}


variable "repository_url" {
  type        = string
}


variable "privatesubnet" {
  type        = list(string)
}


variable "nats_repo" {
  type        = string
}

variable "aws_lb_target_group_arn" {
  description = "target group arn"
  type        = string
}