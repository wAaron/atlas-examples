provider "aws" {
    access_key = "YOUR_ACCESS_KEY_HERE"
    secret_key = "YOUR_SECRET_KEY_HERE"
    region = "us-east-1"
}

resource "atlas_artifact" "consul" {
    name = "<username>/consul"
    type = "aws.ami"
}

resource "aws_instance" "consul" {
    instance_type = "t2.micro"
    ami = "${atlas_artifact.consul.metadata_full.region-us-east-1}"

    # This will create 3 instances
    count = 3
}