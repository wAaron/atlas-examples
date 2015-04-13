provider "atlas" {
    token = "${var.atlas_token}"
}

provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.region}"
}

resource "atlas_artifact" "metamon" {
    name = "${var.atlas_username}/metamon_4"
    type = "aws.ami"

   # Automatically generates key pair if not present
   provisioner "local-exec" {
       command = "sh scripts/generate_key_pair.sh metamon ${var.region}"
   }
}

resource "atlas_artifact" "consul" {
    name = "${var.atlas_username}/consul_4"
    type = "aws.ami"

   # Automatically generates key pair if not present
   provisioner "local-exec" {
       command = "sh scripts/generate_key_pair.sh consul ${var.region}"
   }
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

resource "aws_key_pair" "metamon" {
    key_name = "metamon-key-pair-${var.region}"
    public_key = "${file(\"ssh_keys/metamon-key-pair-${var.region}.pub\")}"
    depends_on = ["atlas_artifact.metamon"]
}

resource "aws_key_pair" "consul" {
    key_name = "consul-key-pair-${var.region}"
    public_key = "${file(\"ssh_keys/consul-key-pair-${var.region}.pub\")}"
    depends_on = ["atlas_artifact.consul"]
}

module "metamon" {
    source = "./metamon"
    ami = "${atlas_artifact.metamon.metadata_full.region-us-east-1}"
    security_group = "${aws_security_group.allow_all.name}"
    key_name = "${aws_key_pair.metamon.key_name}"
    instance_type = "${var.metamon_instance_type}"
    availability_zone = "${var.metamon_availability_zone}"
    count = "${var.metamon_count}"
    atlas_username = "${var.atlas_username}"
    atlas_token = "${var.atlas_token}"
    atlas_environment = "${var.atlas_environment}"
    key_file = "ssh_keys/metamon-key-pair-${var.region}.pem"
}

module "consul" {
    source = "./consul"
    ami = "${var.consul_ami}"
    # ami = "${atlas_artifact.consul.metadata_full.region-us-east-1}"
    security_group = "${aws_security_group.allow_all.name}"
    key_name = "${aws_key_pair.consul.key_name}"
    instance_type = "${var.consul_instance_type}"
    availability_zone = "${var.consul_availability_zone}"
    count = "${var.consul_count}"
    atlas_username = "${var.atlas_username}"
    atlas_token = "${var.atlas_token}"
    atlas_environment = "${var.atlas_environment}"
    key_file = "ssh_keys/consul-key-pair-${var.region}.pem"
}
