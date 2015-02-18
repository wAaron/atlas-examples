Consul
===================
This repository and walkthrough guides you through deploying a Consul cluster on AWS.

General setup
-------------
1. Clone this repository
2. Create an Atlas account
3. Generate an [Atlas token](https://atlas.hashicorp.com/settings/tokens) and save as environment variable. 
`export ATLAS_TOKEN=<your_token>`
4. In the Packer files `consul.json` and Terraform file `consul.tf` you need to replace all instances of `<username>`,  `YOUR_SECRET_HERE`, and `YOUR_KEY_HERE` with your Atlas username and AWS keys. 

Introduction and Configuring Consul
------------------------------------
Before jumping into configuration steps, it's helpful to have a mental model for configuring Consul and how the Atlas workflow fits in. [Consul](https://consul.io) is a tool for service discovery and configuration. A Consul agent lives on each of your nodes and reports both the service on the node (web server, database, worker, etc) and the health of the node. The end result is a real-time registry of services and their health, which can be used for service discovery and general architecture configuration. To learn more about Consul, its feature set, and interal workings, definitely check out its [dedicated website](https://consul.io).

To deploy Consul with Atlas, we'll first create an AMI with a Packer configuration and then deploy that AMI with a Terraform configuration. This walkthrough assumes you have both [Packer](http://www.packer.io/intro/getting-started/setup.html) and [Terraform](https://www.terraform.io/intro/getting-started/install.html) installed on your machine. 

Step 1: Build a Consul AMI
---------------------
1. Build an AMI with Consul installed. To do this, run `packer push -create consul.json` in the ops directory. This will send the build configuration to Atlas so it can build your Consul AMI remotely. 
2. View the status of your build in the Operations tab of your [Atlas account](atlas.hashicorp.com/operations).

Step 2: Deploy a Three-node Consul Cluster
-----------------------------------
1. To deploy a three-node Consul cluster, all you need to do is run `terraform apply` in the terraform folder. Be sure to run `terraform apply` only on the artifact first. The easiest way to do this is comment out the `aws_instance` resource and then run `terraform apply`. Once the artifact is created, just uncomment the `aws_instance` resource and run `terraform apply` on the full configuration. Watch Terraform provision three instances with Consul installed
```
provider "aws" {
    access_key = "YOUR_KEY_HERE"
    secret_key = "YOUR_SECRET_HERE"
    region = "us-east-1"
}

resource "atlas_artifact" "consul" {
    name = "<username>/consul"
    type = "aws.ami"
}

// resource "aws_instance" "consul" {
//     instance_type = "t2.small"
//     ami = "${atlas_artifact.consul.metadata_full.region-us-east-1}"

//     # This will create 3 instances
//     count = 3
// }
```

Step 3: Create the Cluster
------------------------
1. Now that the instances are provisioned, we need to connect them together. First, run `terraform show` to reveal the instance details (public IP, private IP, etc). Then SSH into one of the machines and join the cluster together by running `consul join <Node A Address> <Node B Address> <Node C Address>` with the Private IPs of your newly created instances. Run `consul members` to validate that the cluster is formed.
2. That's it! You just deployed a Consul cluster.
