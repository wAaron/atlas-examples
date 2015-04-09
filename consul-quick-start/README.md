Consul
===================
This repository and walkthrough guides you through deploying a Consul cluster on AWS.

General setup
-------------
1. [Download](https://www.terraform.io/downloads.html) and [install](https://www.terraform.io/intro/getting-started/install.html) Terraform.
2. Clone this repository.
3. Create an [Atlas account](https://atlas.hashicorp.com/account/new?utm_source=github&utm_medium=examples&utm_campaign=consul-quick-start) and save your Atlas username as an environment variable in your `.bashrc` file.
  1. `export ATLAS_USERNAME=<your_atlas_username>`
4. Generate an [Atlas token](https://atlas.hashicorp.com/settings/tokens) and save as an environment variable in your `.bashrc` file.
  1. `export ATLAS_TOKEN=<your_atlas_token>`
5. Get your [AWS access and secret keys](http://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSGettingStartedGuide/AWSCredentials.html) and save as environment variables in your `.bashrc` file.
  1. `export AWS_ACCESS_KEY=<your_aws_access_key>`
  2. `export AWS_SECRET_KEY=<your_aws_secret_key>`
6. When running `terraform` you can either pass environment variables into each call as noted in [ops/terraform/variables.tf](ops/terraform/variables.tf#L6), or replace `YOUR_AWS_ACCESS_KEY`, `YOUR_AWS_SECRET_KEY`, `YOUR_ATLAS_USERNAME`, `YOUR_ATLAS_TOKEN`, and `YOUR_ATLAS_ENVIRONMENT_NAME` with your Atlas username, Atlas token, [AWS Access Key Id, AWS Secret Access key](http://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSGettingStartedGuide/AWSCredentials.html), and desired Atlas environment name in [ops/terraform/terraform.tfvars](ops/terraform/terraform.tfvars). If you use terraform.tfvars, you don't need to pass in environment variables for each `terraform` call, just be sure not to check this into a public repository.
7. Generate the consul key pair in [ops/terraform/ssh_keys](ops/terraform/ssh_keys). You can use your own public/private key pair as long as the public key is in valid OpenSSH public key format, or you can simply run `scripts/generate_key_pair.sh` from the [ops](ops) directory and it will generate them for you. The private key must be named `ops/terraform/scripts/consul-key.pem` and the public key must be named `ops/terraform/scripts/consul-key.pem`, the script will take care of this for you.

_\** If you would like to build your own Consul cluster AMI with Packer to use instead of ours, you will want to replace `YOUR_ATLAS_USERNAME` and `YOUR_ATLAS_BUILD_NAME` in [ops/consul.json](ops/consul.json) with your Atlas username and desired Atlas build configuration name. However, this is not necessary for the following steps to work as we are already referencing a previously built public Consul AMI in the Terraform template. If you choose to build your own, be sure to override the default "ami" variable in [ops/terraform/variables.tf](ops/terraform/variables.tf#L27) by uncommenting "ami" in [ops/terraform/terraform.tfvars](ops/terraform/terraform.tfvars#L17) and updating with your new AMI id. Alternatively, if you don't want to use a static AMI id, you can update your [ops/terraform/main.tf](ops/terraform/main.tf) template to add your Atlas artifact as a resource and reference that [here](ops/terraform/main.tf#L33) instead._

Introduction and Configuring Consul
------------------------------------
Before jumping into configuration steps, it's helpful to have a mental model for configuring Consul and how the Atlas workflow fits in. [Consul](https://consul.io) is a tool for service discovery and configuration. A Consul agent lives on each of your nodes and reports both the service on the node (web server, database, worker, etc) and the health of the node. The end result is a real-time registry of services and their health, which can be used for service discovery and general architecture configuration. To learn more about Consul, its feature set, and interal workings, definitely check out its [dedicated website](https://consul.io).

Step 1: Deploy a Three-node Consul Cluster
-----------------------------------
1. Make sure you are in the [ops/terraform](ops/terraform) directory.
2. Run `terraform remote config -backend-config name=<your_atlas_username>/<your_atlas_environment_name>` in the [ops/terraform](ops/terraform) directory, replacing `<your_atlas_username>` with your Atlas username and `<your_atlas_environment_name>` with your desired Atlas environment name to configure [remote state storage](https://www.terraform.io/docs/commands/remote-config.html) for this infrastructure. Now when you run Terraform, the infrastructure state will be saved in Atlas. This keeps a versioned history of your infrastructure.
3. Get the latest consul module by running `terraform get` in the [ops/terraform](ops/terraform) directory.
4. To deploy your three-node Consul cluster, all you need to do is run `terraform apply` in the [ops/terraform](ops/terraform) directory. Now watch Terraform provision a three-node Consul cluster!

Step 2: View your Consul Cluster
------------------------
1. Navigate to the [Environments tab](https://atlas.hashicorp.com/environments) in your Atlas account and click on the newly created environment. You'll now see the real-time health of all your nodes and services!
2. That's it! You just deployed a Consul cluster.

Cleanup
------------------------
1. Run `terraform destroy` to tear down any infrastructure you created. If you want to bring it back up, simply run `terraform apply` and it will bring your infrastructure back to the state it was last at.
