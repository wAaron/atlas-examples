HAProxy and Node.js
===================
This repository and walkthrough guides you through deploying HAProxy and Node.js on AWS.

General setup
-------------
1. Clone this repository
2. Create an Atlas account
3. Generate an [Atlas token](https://atlas.hashicorp.com/settings/tokens) and save as environment variable. 
`export ATLAS_TOKEN=<your_token>`
4. In the Vagrantfile, Packer files `haproxy.json` and `nodejs.json`, Terraform file `infrastructure.tf`, and Consul upstart script `consul_client.conf` you need to replace all instances of `<username>`,  `YOUR_ATLAS_TOKEN`, `YOUR_SECRET_HERE`, and `YOUR_KEY_HERE` with your Atlas username, Atlas token, and AWS keys.

Introduction and Configuring HAProxy + Node.js
-----------------------------------------------
Before jumping into configuration steps, it's helpful to have a mental model for how services connect and how the Atlas workflow fits in. 

For HAProxy to work properly, it needs to have a real-time list of backend nodes to balance traffic between. In this example, HAProxy needs to have a real-time list of healthy Node.js nodes. To accomplish this, we use [Consul](https://consul.io) and [Consul Template](https://github.com/hashicorp/consul-template). Any time a server is created, destroyed, or changes in health state, the HAProxy configuration updates to match by using the Consul Template `haproxy.ctmpl`. Pay close attention to the backend stanza:

```
backend webs
    balance roundrobin
    mode http{{range service "nodejs.web"}}
    server {{.Node}} {{.Address}}:{{.Port}}{{end}}
```

Consul Template will query Consul for all web servers with the tag "nodejs", and then iterate through the list to populate the HAProxy configuration. When rendered, `haproxy.cfg` will look like:

```
backend webs
    balance roundrobin
    mode http
    server node1 172.29.28.10:8888
    server node2 172.56.28.10:8888
```
This setup allows us to destroy and create backend servers at scale with confidence that the HAProxy configuration will always be up-to-date. You can think of Consul and Consul Template as the connective webbing between services. 

Step 1: Create a Consul Cluster
-------------------------
1. For Consul Template to work for HAProxy, we first need to create a Consul cluster. You can follow [this walkthrough](https://github.com/hashicorp/atlas-examples/tree/master/consul) to guide you through that process. 

Step 2: Build an HAProxy AMI
---------------------
1. Build an AMI with HAProxy installed. To do this, run `packer push -create haproxy.json` in the HAProxy packer directory. This will send the build configuration to Atlas so it can build your HAProxy AMI remotely. 
2. View the status of your build in the Operations tab of your [Atlas account](atlas.hashicorp.com/operations).

Step 3: Build a Node.js AMI
-------------------
1. Build an AMI with Node.js installed. To do this, run `packer push -create nodejs.json` in the Node.js packer directory. This will send the build configuration to Atlas so it can build your HAProxy AMI remotely. 
2. View the status of your build in the Operations tab of your [Atlas account](atlas.hashicorp.com/operations).
3. This creates an AMI with Node.js installed, and now you need to send the actual Node.js application code to Atlas and link it to the build configuration. To do this, simply run `vagrant push` in the app directory. This will send your Node.js application, which is just the `server.js` file for now. Then link the Node.js application with the Node.js build configuration by clicking on your build configuration, then 'Links' in the left navigation. Complete the form with your username, 'nodejs' as the application name, and '/app' as the destination path.
4. Now that your application and build configuration are linked, simply rebuild the Node.js configuration and you will have a fully-baked AMI with Node.js installed and your application code in place.

Step 4: Deploy HAProxy and Node.js
--------------------------
1. To deploy HAProxy and Node.js, all you need to do is run `terraform apply` in the ops/terraform folder. Be sure to run `terraform apply` only on the artifacts first. The easiest way to do this is comment out the `aws_instance` resources and then run `terraform apply`. Once the artifacts are created, just uncomment the `aws_instance` resources and run `terraform apply` on the full configuration. Watch Terraform provision three instances — two with Node.js and one with HAProxy! 
```
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

// resource "aws_security_group" "haproxy" {
//   name = "haproxy"
//     description = "Allow all inbound traffic"

//   ingress {
//       from_port = 0
//       to_port = 65535
//       protocol = "all"
//       cidr_blocks = ["0.0.0.0/0"]
//   }
// }

// resource "aws_instance" "nodejs" {
//     instance_type = "t2.small"
//     ami = "${atlas_artifact.nodejs.metadata_full.region-us-east-1}"
//     security_groups = ["${aws_security_group.haproxy.name}"]

//     # This will create 2 instances
//     count = 2
//     lifecycle = {
//       create_before_destroy = true  
//     }
// }

// resource "aws_instance" "haproxy" {
//     instance_type = "t2.small"
//     ami = "${atlas_artifact.haproxy.metadata_full.region-us-east-1}"
//     security_groups = ["${aws_security_group.haproxy.name}"]

//     # This will create 1 instance
//     count = 1
//     lifecycle = {
//       create_before_destroy = true  
//     }
// }
```

Final Step: Test HAProxy
------------------------
1. Navigate to your HAProxy stats page by going to it's Public IP on port 1936 and path /haproxy?stats. For example 52.1.212.85:1936/haproxy?stats
2. In a new tab, hit your HAProxy Public IP on port 8080 a few times. You'll see in the stats page that your requests are being balanced evenly between the Node.js nodes. 
3. That's it! You just deployed HAProxy and Node.js
4. Navigate to the [Runtime tab](https://atlas.hashicorp.com/runtime) in your Atlas account and click on the newly created infrastructure. You'll now see the real-time health of all your nodes and services!
