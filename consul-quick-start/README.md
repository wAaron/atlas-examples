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
6. When running `terraform` you can either pass environment variables into each call as noted in [ops/terraform/variables.tf#L6](ops/terraform/variables.tf#L6), or replace `YOUR_AWS_ACCESS_KEY`, `YOUR_AWS_SECRET_KEY`, `YOUR_ATLAS_USERNAME`, `YOUR_ATLAS_TOKEN`, and `YOUR_ATLAS_ENVIRONMENT_NAME` with your Atlas username, Atlas token, [AWS Access Key Id, AWS Secret Access key](http://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSGettingStartedGuide/AWSCredentials.html), and desired Atlas environment name in [ops/terraform/terraform.tfvars](ops/terraform/terraform.tfvars). If you use terraform.tfvars, you don't need to pass in environment variables for each `terraform` call, just be sure not to check this into a public repository.
7. Generate the consul key pair in [ops/terraform/ssh_keys](ops/terraform/ssh_keys). You can use your own existing key pair as long as the public key material format is [supported](https://www.terraform.io/docs/providers/aws/r/key_pair.html), or you can simply run `sh scripts/generate_key_pair.sh` from the [ops/terraform](ops/terraform) directory and it will generate the keys for you. The private key must be named [ops/terraform/ssh_keys/consul-key.pem](ops/terraform/ssh_keys/consul-key.pem) and the public key must be named [ops/terraform/ssh_keys/consul-key.pub](ops/terraform/ssh_keys/consul-key.pub), the script will take care of this for you. If you don't update the key pair or run the script, you will see the error `* Error import KeyPair: The request must contain the parameter PublicKeyMaterial` on `terraform apply`.

_\** If you would like to build your own Consul cluster AMI with Packer to use instead of ours, see the below section [Build Your Own Consul Cluster AMI with Packer](README.md#build-your-own-consul-cluster-ami-with-packer). Note that this is not necessary for the following steps to work as we are already referencing a previously built public Consul AMI in the Terraform template._

Introduction and Configuring Consul
------------------------------------
Before jumping into configuration steps, it's helpful to have a mental model for configuring Consul and how the Atlas workflow fits in. [Consul](https://consul.io) is a tool for service discovery and configuration. A Consul agent lives on each of your nodes and reports both the service on the node (web server, database, worker, etc) and the health of the node. The end result is a real-time registry of services and their health, which can be used for service discovery and general architecture configuration. To learn more about Consul, its feature set, and interal workings, definitely check out its [dedicated website](https://consul.io).

Deploy a Three-node Consul Cluster
-----------------------------------
1. Navigate to the [ops/terraform](ops/terraform) directory on the command line.
2. Run `terraform remote config -backend-config name=<your_atlas_username>/<your_atlas_environment_name>` in the [ops/terraform](ops/terraform) directory, replacing `<your_atlas_username>` with your Atlas username and `<your_atlas_environment_name>` with your desired Atlas environment name to configure [remote state storage](https://www.terraform.io/docs/commands/remote-config.html) for this infrastructure. Now when you run Terraform, the infrastructure state will be saved in Atlas, keeping a versioned history of your infrastructure.
3. Get the latest consul module by running `terraform get` in the [ops/terraform](ops/terraform) directory.
4. To deploy your three-node Consul cluster, all you need to do is run `terraform push -name <your_atlas_username>/<your_atlas_environment_name>` in the [ops/terraform](ops/terraform) directory, replacing `<your_atlas_username>` with your Atlas username and `<your_atlas_environment_name>` with your desired Atlas environment name used above.
5. Go to the [Environments tab](https://atlas.hashicorp.com/environments) in your Atlas account and click on the newly created environment. Navigate to "Changes" on the left side panel of the your newly created environment. Click the "Confirm & Apply" button to deploy your Consul cluster.
   ![Confirm & Apply](screenshots/environments_changes_confirm.png?raw=true)
6. That's it! You just deployed a Consul cluster. In "Changes" you can view all of your configuration and state changes, as well as deployments. If you navigate back to "Status" on the left side panel, you will see the real-time health of all your nodes and services!
   ![Consul Infrastructure Status](screenshots/environments_status.png?raw=true)

Cleanup
------------------------
1. Run `terraform destroy` to tear down any infrastructure you created. If you want to bring it back up, simply run `terraform push -name <your_atlas_username>/<your_atlas_environment_name>` and it will bring your infrastructure back to the state it was last at.

Build Your Own Consul Cluster AMI with Packer
------------------------
1. Make sure you have [Packer](https://packer.io/) [downloaded](https://www.packer.io/downloads.html) and [installed](https://www.packer.io/intro/getting-started/setup.html).
2. Replace `YOUR_ATLAS_USERNAME` and `YOUR_ATLAS_BUILD_NAME` in [ops/consul.json](ops/consul.json) with your Atlas username and desired Atlas build configuration name.
3. Navigate to the [ops](ops) directory on the command line.
4. Run `packer push -create consul.json` in the [ops](ops) directory.
5. Navigate to "Variables" on the left side panel of the your new build configuration in the [Builds tab](https://atlas.hashicorp.com/builds) of your Atlas account, then add the key `AWS_ACCESS_KEY` using your "AWS Access Key Id" as the value and the key `AWS_SECRET_KEY` using your "AWS Secret Access Key" as the value.
6. Navigate back to "Versions" on the left side panel of your build configuration, then click "Rebuild" on the your build configuration that errored. This one should succeed.
7. Update your [ops/terraform/main.tf](ops/terraform/main.tf) template to add your Atlas artifact as a resource and reference that artifact in the [consul module](ops/terraform/main.tf#L33) instead of the "ami" variable. See below code snippet - be sure to replace `YOUR_ATLAS_BUILD_NAME` with the build configuration name you chose in the above Packer template.

   ```
   provider "atlas" {
       token = "${var.atlas_token}"
   }

   resource "atlas_artifact" "YOUR_ATLAS_BUILD_NAME" {
       name = "${var.atlas_username}/YOUR_ATLAS_BUILD_NAME"
       type = "aws.ami"

       # Automatically generates key pair if not provided
       provisioner "local-exec" {
           command = "sudo scripts/generate_key_pair.sh"
       }
   }

   ...

   # Replace ami = "${var.ami}" (ops/terraform/main.tf#L33) with the below
   ami = "${atlas_artifact.YOUR_ATLAS_BUILD_NAME.metadata_full.region-us-east-1}"
   ```
8. Remove the "ami" variable from [ops/terraform/variables.tf#L26](ops/terraform/variables.tf#L26) and [ops/terraform/terraform.tfvars#L17](ops/terraform/terraform.tfvars#L17) as these are no longer required.
9. Refer to [Deploy a Three-node Consul Cluster](README.md#deploy-a-three-node-consul-cluster) to deploy using Terraform!
