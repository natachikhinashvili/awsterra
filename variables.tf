variable "region" {
    type = string
}

variable "bucket_name" {
    type = string
}

variable "azs" {
  type    = list(string)
}

variable "publicsubnet" {
  type    = string
}