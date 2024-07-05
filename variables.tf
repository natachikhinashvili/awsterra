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

variable "vpcname" {
  type = string
}

variable "db_name" {
  type = string
}

variable "username" {
  type = string
}

variable "password" {
  type = string
}

variable "capacityprovidername" {
  type = string
}

variable "repositoryname" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "template_name" {
  type = string
}
variable "instanceprofilename" {
  type = string
}