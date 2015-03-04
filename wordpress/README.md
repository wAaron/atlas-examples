Setup Wordpress on AWS
===================
This repository and walkthrough guides you through deploying a Wordpress Application on AWS.

General setup
-------------
1. Clone this repository
2. Create an Atlas account
3. Generate an [Atlas token](https://atlas.hashicorp.com/settings/tokens) and save as environment variable. 
`export ATLAS_TOKEN=<your_token>`
4. In the Vagrantfile, Packer files `apache-php.json` and `mysql.json`, Terraform file `lamp.tf`, and consul upstart configuration `consul_client.conf` you need to replace all instances of `<username>`,  `YOUR_ATLAS_TOKEN`, `YOUR_SECRET_HERE`, and `YOUR_KEY_HERE` with your Atlas username, Atlas token, and AWS keys.

Introduction and Configuring Wordpress Infrastructure
-----------------------------------------------
Before jumping into configuration steps, it's helpful to have a mental model for how services connect and how the Atlas workflow fits in.

Wordpress must be deployed on a LAMP stack, and in this example it's deployed to AWS. For LAMP to work properly in a distributed system, the servers running Apache+PHP must know which servers are running MySQL. To accomplish this, we use [Consul](https://consul.io) and [Consul Template](https://github.com/hashicorp/consul-template). Any time a server is created, destroyed, or changes in health state, the PHP and Wordpress configuration updates to match by using the Consul Template `php.ctmpl` and `wp-config.ctmpl`. Pay close attention to the database connection details:

```
$password = "password";{{range service "mysql.database"}}
$hostname = "{{.Address}}"{{end}};
```

Consul Template will query Consul for all "database" servers with the tag "mysql", and then iterate through the list to populate the PHP configuration. When rendered, `my.cnf` will look like:

```
$password = "password";
$hostname = "172.29.28.10";
```
This setup allows us to destroy and create Apache+PHP servers with confidence that their configurations will always be correct and they will always write to the proper MySQL instances. You can think of Consul and Consul Template as the connective webbing between services. 

Step 1: Create a Consul Cluster
-------------------------
1. For Consul Template to work for LAMP, we first need to create a Consul cluster. You can follow [this walkthrough](https://github.com/hashicorp/atlas-examples/tree/master/consul) to guide you through that process. 

Step 2: Build a Wordpress AMI
---------------------
1. Build an AMI with the Wordpress requirements Apache and PHP installed. To do this, run `packer push -create apache-php.json` in the ops directory. This will send the build configuration to Atlas so it can remotely build your AMI with Apache and PHP installed.
2. View the status of your build in the Operations tab of your [Atlas account](atlas.hashicorp.com/operations).
3. This creates an AMI with Apache and PHP installed, and now you need to send the actual Wordpress application code to Atlas and link it to the build configuration. To do this, simply run `vagrant push` in the app directory. This will send your full Wordpress application code to Atlas. Then link the Wordpress application with the Apache+PHP build configuration by clicking on your build configuration, then 'Links' in the left navigation. Complete the form with your username, 'wordpress' as the application name, and '/app' as the destination path.
4. Now that your application and build configuration are linked, simply rebuild the Apache+PHP configuration and you will have a fully-baked AMI with Apache and PHP installed and your Wordpress application code in place.

Step 3: Build a MySQL AMI
-------------------
1. Build an AMI with MySQL installed. To do this, run `packer push -create mysql.json` in the ops directory. This will send the build configuration to Atlas so it can build your MySQL AMI remotely. 
2. View the status of your build in the Operations tab of your [Atlas account](atlas.hashicorp.com/operations).

Step 4: Deploy Wordpress
--------------------------
1. To deploy the Wordpress stack, all you need to do is run `terraform apply` in the ops/terraform folder. Be sure to run `terraform apply` only on the artifacts first. The easiest way to do this is comment out the `aws_instance` resources and then run `terraform apply`. Once the artifacts are created, just uncomment the `aws_instance` resources and run `terraform apply` on the full configuration. Watch Terraform provision two instances â€” one with Apache+PHP and one with MySQL! 
```
provider "aws" {
    access_key = "YOUR_KEY_HERE"
    secret_key = "YOUR_SECRET_HERE"
    region = "us-east-1"
}

resource "atlas_artifact" "php" {
    name = "<username>/apache-php"
    type = "aws.ami"
}

resource "atlas_artifact" "mysql" {
    name = "<username>/mysql"
    type = "aws.ami"
}

// resource "aws_security_group" "allow_all" {
//   name = "allow_all"
//     description = "Allow all inbound traffic"

//   ingress {
//       from_port = 0
//       to_port = 65535
//       protocol = "-1"
//       cidr_blocks = ["0.0.0.0/0"]
//   }
// }

// resource "aws_instance" "php" {
//     instance_type = "t2.micro"
//     ami = "${atlas_artifact.php.metadata_full.region-us-east-1}"
//     security_groups = ["${aws_security_group.allow_all.name}"]

//     # This will create 1 instance
//     count = 1
//     lifecycle = {
//       create_before_destroy = true  
//     }
// }

// resource "aws_instance" "mysql" {
//     instance_type = "t2.micro"
//     ami = "${atlas_artifact.mysql.metadata_full.region-us-east-1}"
//     security_groups = ["${aws_security_group.allow_all.name}"]

//     # This will create 1 instance
//     count = 1
//     lifecycle = {
//       create_before_destroy = true  
//     }
// }
```

Final Step: Test Wordpress Application
--------------------------------
1. Navigate to the Public IP of your Wordpress server. Run `terraform show` to easily find this information. You should see an Apache welcome page. Navigate to `<public_ip>/wordpress` to see your application.
2. That's it! You just deployed a Wordpress application on AWS. Now whenever you make a change to your Wordpress code locally, just run `vagrant push` in the app folder to build new artifacts, then run `terraform apply` in the ops/terraform folder to deploy them out.

Local Development
------------------
This project uses [Scotch Box](https://box.scotch.io/) for local development with [Vagrant](https://vagrantup.com). Just run `vagrant up` in the app directory to bring up a fully functional local Wordpress development environment. Navigate to 192.168.33.10/wordpress to view changes to your Wordpress instance locally.
