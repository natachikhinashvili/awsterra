provider "aws" {
  region = var.region
}

variable "service_name" {
  type = string
}

variable "container_name" {
  type = string
}