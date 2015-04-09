variable "atlas_username" {}
variable "atlas_token" {}
variable "atlas_environment" {}
variable "ami" {}
variable "instance_type" {}
variable "availability_zone" {}
variable "count" {}
variable "security_group" {}
variable "key_name" {}
variable "user" {
    default = "ubuntu"
}
variable "key_file" {}
variable "agent" {
    default = false
}
