variable "security_group_ids" {
  description = "List of security group IDs"
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
  description = "target group arn"
  type        = string
}

variable "service_name" {
  type = string
}

variable "container_name" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "capacityprovidername" {
  type = string
}

variable "template_name" {
  type = string
}
variable "instanceprofilename" {
  type = string
}