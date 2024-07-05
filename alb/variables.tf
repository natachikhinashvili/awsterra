variable "security_group_id" {
  type        = string
}

variable "vpc_id" {
  type        = string
}

variable "subnets" {
  type = list(string)
}