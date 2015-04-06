/* These can be passed in through the command line by
referencing environment variables, or you can use
a terraform.tfvars file, see below example

terraform plan \
    -var 'atlas_username=${ATLAS_USERNAME}' \
    -var 'atlas_token=${ATLAS_TOKEN}' \
    -var 'aws_access_key=${AWS_SECRET_KEY}' \
    -var 'aws_secret_key=${AWS_SECRET_KEY}'

See https://www.terraform.io/intro/getting-started/variables.html */

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
