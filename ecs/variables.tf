variable "security_group_ids" {
  type        = string
}

variable "subnet" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}


variable "repository_url" {
  type = string
}


variable "privatesubnet" {
  type = list(string)
}

variable "aws_lb_target_group_arn" {
  type        = string
}