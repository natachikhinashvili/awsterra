variable "subnetgroup" {
    type = string
}
variable "securitygroup" {
    type = list(string)
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