/* These can be passed in through the command line by
referencing environment variables, or you can use
a terraform.tfvars file, see below example

terraform apply \
    -var "atlas_username=${ATLAS_USERNAME}" \
    -var "atlas_token=${ATLAS_TOKEN}" \
    -var "aws_access_key=${AWS_ACCESS_KEY}" \
    -var "aws_secret_key=${AWS_SECRET_KEY}"

See https://www.terraform.io/intro/getting-started/variables.html */

variable "atlas_username" {}
variable "atlas_token" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "region" {
    default = "us-east-1"
}
variable "aws_key_pair_name" {
    default = "YOUR_AWS_KEY_PAIR_NAME"
}
variable "availability_zone" {
    default = "us-east-1a"
}
