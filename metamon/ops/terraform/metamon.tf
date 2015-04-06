provider "atlas" {
    token = "${var.atlas_token}"
}

provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.region}"
}

resource "atlas_artifact" "metamon" {
    name = "${var.atlas_username}/metamon"
    type = "aws.ami"
}

resource "aws_security_group" "allow_all" {
    name = "allow_all"
    description = "Allow all inbound traffic"

    tags {
      Name = "allow_all"
    }

    ingress {
        from_port = 0
        to_port = 65535
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "metamon" {
    ami = "${atlas_artifact.metamon.metadata_full.region-us-east-1}"
    instance_type = "t2.micro"
    security_groups = ["${aws_security_group.allow_all.name}"]
    key_name = "${var.aws_key_pair_name}"
    availability_zone = "${var.availability_zone}"
    count = 1

    tags {
      Name = "metamon_${count.index+1}"
    }
}

resource "atlas_artifact" "consul" {
    name = "${var.atlas_username}/consul"
    type = "aws.ami"
}

resource "aws_instance" "consul" {
    ami = "${atlas_artifact.consul.metadata_full.region-us-east-1}"
    instance_type = "t2.micro"
    security_groups = ["${aws_security_group.allow_all.name}"]
    key_name = "${var.aws_key_pair_name}"
    availability_zone = "${var.availability_zone}"
    count = 1

    tags {
      Name = "consul_${count.index+1}"
    }
}
