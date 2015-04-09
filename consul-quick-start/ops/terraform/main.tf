provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.region}"
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

resource "aws_key_pair" "consul" {
    key_name = "consul-key"
    public_key = "${file(\"ssh_keys/consul-key.pub\")}"
}

module "consul" {
    source = "./consul"
    atlas_username = "${var.atlas_username}"
    atlas_token = "${var.atlas_token}"
    atlas_environment = "${var.atlas_environment}"
    ami = "${var.ami}"
    instance_type = "${var.instance_type}"
    availability_zone = "${var.availability_zone}"
    count = "${var.count}"
    security_group = "${aws_security_group.allow_all.name}"
    key_name = "${aws_key_pair.consul.key_name}"
    key_file = "ssh_keys/consul-key.pem"
}
