variable "atlas_username" {}
variable "atlas_token" {}
variable "ami" {}
variable "instance_type" {}
variable "availability_zone" {}
variable "count" {}
variable "atlas_environment" {}
variable "security_group" {}
variable "key_name" {}
variable "user" {
    default = "ubuntu"
}
variable "key_file" {}
variable "agent" {
    default = false
}
