/* The variables required for a Terraform command to run properly
can be passed in along with the Terraform command as shown below,
or you can use the terraform.tfvars file and Terraform will grab the
variables from there and all you will have to run is 'terraform apply'

terraform apply \
    -var "aws_access_key=${AWS_ACCESS_KEY}" \
    -var "aws_secret_key=${AWS_SECRET_KEY}" \
    -var "atlas_username=${ATLAS_USERNAME}" \
    -var "atlas_token=${ATLAS_TOKEN}" \
    -var "atlas_environment=YOUR_ATLAS_ENVIRONMENT_NAME"

See https://www.terraform.io/intro/getting-started/variables.html */

# Required Variables
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "atlas_username" {}
variable "atlas_token" {}
variable "atlas_environment" {}

# Optional Configuration Variables
variable "region" {
    default = "us-east-1"
}
variable "ami" {
    default = "ami-dc1529b4"
}
variable "instance_type" {
    default = "t2.micro"
}
variable "availability_zone" {
    default = "us-east-1a"
}
variable "count" {
    default = 3
}