/* These required variables can be passed in through the command line by
referencing environment variables (below example), or you can use
a terraform.tfvars file and terraform will grab these vars from there
and all you have to run is 'terraform apply'

terraform apply \
    -var "atlas_username=${ATLAS_USERNAME}" \
    -var "atlas_token=${ATLAS_TOKEN}" \
    -var "aws_access_key=${AWS_ACCESS_KEY}" \
    -var "aws_secret_key=${AWS_SECRET_KEY}"

See https://www.terraform.io/intro/getting-started/variables.html */

# Required Credentials
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "atlas_username" {}
variable "atlas_token" {}

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
variable "atlas_environment" {
    default = "YOUR_ATLAS_ENVIRONMENT_NAME"
}
