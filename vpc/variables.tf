variable "vpcname" {
  type = string
}

variable "privatesubnet" {
  type = string
}

variable "publicsubnet" {
  type = string
}

variable "azs" {
  type = list(string)
}