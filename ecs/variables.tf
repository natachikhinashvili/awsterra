variable "security_group_ids" {
  description = "List of security group IDs"
  type        = string
}

variable "subnet" {
  type        = list(string)
}