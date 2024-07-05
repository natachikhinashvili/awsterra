variable "subnetgroup" {
  type = string
}
variable "securitygroup" {
  type = list(string)
}
variable "username" {
  type = string
}
variable "password" {
  type = string
}
variable "db_name" {
  type = string
  default = "natsdb"
}