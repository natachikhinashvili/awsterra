variable "region" {
    type = string
}

variable "bucket_name" {
    type = string
}


variable "azs" {
  type    = list(string)
}
variable "vpc_id" {
  type    = string
}