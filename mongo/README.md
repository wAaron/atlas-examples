MongoDB
==============
This repository and walkthrough guides you through deploying MongoDB on AWS.

General setup
-------------
1. Create an Atlas account
2. Generate an [Atlas token](https://atlas.hashicorp.com/settings/tokens) and save as environment variable. `export ATLAS_TOKEN=<your_token>`
3. Clone this repository
4. In the Packer file `mongo.json` and Terraform file `mongo.tf` you need to replace all instances of `<username>`,  `YOUR_SECRET_HERE`, and `YOUR_KEY_HERE` with your Atlas username and AWS keys. 

Deploy Mongo
------------
1. First you need to build an AMI with MongoDB installed. To do this, run `packer push -create mongo.json` in the ops directory. This will send the build configuration to Atlas so it can build your AMI remotely. 
2. View the status of your build in the Operations tab of your [Atlas account](atlas.hashicorp.com/operations). When the build completes, you’re now ready to deploy the AMI!
4. To deploy MongoDB, all you need to do is run `terraform apply` in the ops/terraform folder. Be sure to run `terraform apply` only on the artifact first. The easiest way to do this is comment out the `aws_instance` resource and then run `terraform apply`. Once the artifact is created, just uncomment the `aws_instance` resource and run `terraform apply` on the full configuration. Watch Terraform provision an instance with MongoDB! 
```
provider "aws" {
    access_key = "YOUR_KEY_HERE"
    secret_key = "YOUR_SECRET_HERE"
    region = "us-east-1"
}

resource "atlas_artifact" "mongo" {
    name = "<username>/mongo"
    type = "aws.ami"
}

// resource "aws_instance" "mongo" {
//     instance_type = "t2.small"
//     ami = "${atlas_artifact.mongo.metadata_full.region-us-east-1}"

//     # This will create 1 instances
//     count = 1
//     lifecycle = {
//       create_before_destroy = true  
//     }
    
// }
```

Advanced Features
-----------------
If you are running [Consul](https://consul.io) in your cluster for service discovery and health monitoring, it’s easy to update the files in this repo to bring up MongoDB with a Consul agent. In the `consul_client` upstart script, you need to update `<CONSUL_SERVER_IP>` with the IPs of your Consul servers, that’s it!
