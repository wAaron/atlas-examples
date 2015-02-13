provider "aws" {
    access_key = "YOUR_KEY_HERE"
    secret_key = "YOUR_SECRET_HERE"
    region = "us-east-1"
}

resource "atlas_artifact" "mysql" {
    name = "<username>/mysql"
    type = "aws.ami"
}

resource "aws_instance" "mysql" {
    instance_type = "t2.small"
    ami = "${atlas_artifact.mysql.metadata_full.region-us-east-1}"
    security_groups = ["allow_all"]

    # This will create 1 instances
    count = 1
    lifecycle = {
      create_before_destroy = true  
    }
    
}