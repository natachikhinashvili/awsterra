variable "region" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "publicsubnet" {
  type = string
}

variable "privatesubnet" {
  type = string
}