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