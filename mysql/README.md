MySQL
==============
This repository and walkthrough guides you through deploying MySQL on AWS.

General setup
-------------
1. Clone this repository
2. Create an Atlas account
3. Generate an [Atlas token](https://atlas.hashicorp.com/settings/tokens) and save as environment variable. 
`export ATLAS_TOKEN=<your_token>`
4. In the Packer file `mysql.json` and Terraform file `mysql.tf` you need to replace all instances of `<username>`,  `YOUR_SECRET_HERE`, and `YOUR_KEY_HERE` with your Atlas username and AWS keys. 

Deploy MySQL
------------
1. First you need to build an AMI with MySQL installed. To do this, run `packer push -create mysql.json` in the ops directory. This will send the build configuration to Atlas so it can build your AMI remotely. 
2. View the status of your build in the Operations tab of your [Atlas account](atlas.hashicorp.com/operations). When the build completes, you’re now ready to deploy the AMI!
4. To deploy MySQL, all you need to do is run `terraform apply` in the ops/terraform folder. Be sure to run `terraform apply` only on the artifact first. The easiest way to do this is comment out the `aws_instance` resource and then run `terraform apply`. Once the artifact is created, just uncomment the `aws_instance` resource and run `terraform apply` on the full configuration. Watch Terraform provision an instance with MySQL! 
```
provider "aws" {
    access_key = "YOUR_KEY_HERE"
    secret_key = "YOUR_SECRET_HERE"
    region = "us-east-1"
}

resource "atlas_artifact" "mysql" {
    name = "<username>/mysql"
    type = "aws.ami"
}

// resource "aws_instance" "mysql" {
//     instance_type = "t2.small"
//     ami = "${atlas_artifact.mysql.metadata_full.region-us-east-1}"

//     # This will create 1 instances
//     count = 1
//     lifecycle = {
//       create_before_destroy = true  
//     }
    
// }
```

Advanced Features
-----------------
If you are running [Consul](https://consul.io) in your cluster for service discovery and health monitoring, it’s easy to update the files in this repo to bring up MySQL with a Consul agent. In the `consul_client` upstart script, you need to update `<CONSUL_SERVER_IP>` with the IPs of your Consul servers, that’s it!
