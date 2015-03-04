provider "aws" {
    access_key = "YOUR_KEY_HERE"
    secret_key = "YOUR_SECRET_HERE"
    region = "us-east-1"
}

resource "atlas_artifact" "nodejs" {
    name = "<username>/nodejs"
    type = "aws.ami"
}

resource "atlas_artifact" "haproxy" {
    name = "<username>/haproxy"
    type = "aws.ami"
}

resource "aws_security_group" "haproxy" {
  name = "haproxy"
    description = "Allow all inbound traffic"

  ingress {
      from_port = 0
      to_port = 65535
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nodejs" {
    instance_type = "t2.micro"
    ami = "${atlas_artifact.nodejs.metadata_full.region-us-east-1}"
    security_groups = ["${aws_security_group.haproxy.name}"]

    # This will create 2 instances
    count = 2
    lifecycle = {
      create_before_destroy = true  
    }
}

resource "aws_instance" "haproxy" {
    instance_type = "t2.micro"
    ami = "${atlas_artifact.haproxy.metadata_full.region-us-east-1}"
    security_groups = ["${aws_security_group.haproxy.name}"]

    # This will create 1 instance
    count = 1
    lifecycle = {
      create_before_destroy = true  
    }
}