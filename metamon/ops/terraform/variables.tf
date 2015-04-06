variable "atlas_username" {}
variable "atlas_token" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "region" {
    default = "us-east-1"
}
variable "ec2_key_name" {
    default = "YOUR_EC2_KEY_NAME"
}
variable "availability_zone" {
    default = "us-east-1a"
}
