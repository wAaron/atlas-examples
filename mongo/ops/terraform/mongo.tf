provider "aws" {
    access_key = "YOUR_KEY_HERE"
    secret_key = "YOUR_SECRET_HERE"
    region = "us-east-1"
}

resource "atlas_artifact" "mongo" {
    name = "<username>/mongo"
    type = "aws.ami"
}

resource "aws_instance" "mongo" {
    instance_type = "t2.small"
    ami = "${atlas_artifact.mongo.metadata_full.region-us-east-1}"

    # This will create 1 instances
    count = 1
    lifecycle = {
      create_before_destroy = true  
    }
    
}