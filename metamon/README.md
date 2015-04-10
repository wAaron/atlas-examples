Metamon
===================
This repository and walkthrough guides you through deploying [Metamon](https://github.com/tryolabs/metamon) on AWS using Atlas.

General setup
-------------
1. Download and install [Virtualbox](https://www.virtualbox.org/wiki/Downloads), [Vagrant](https://www.vagrantup.com/downloads.html), [Packer](https://www.packer.io/downloads.html), and [Terraform](https://www.terraform.io/downloads.html).
2. Clone this repository.
3. Create an [Atlas account](https://atlas.hashicorp.com/account/new?utm_source=github&utm_medium=examples&utm_campaign=metamon) and save your Atlas username as an environment variable in your `.bashrc` file.
   `export ATLAS_USERNAME=<your_atlas_username>`
4. Generate an [Atlas token](https://atlas.hashicorp.com/settings/tokens) and save as an environment variable in your `.bashrc` file.
   `export ATLAS_TOKEN=<your_atlas_token>`
5. Get your [AWS access and secret keys](http://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSGettingStartedGuide/AWSCredentials.html) and save as environment variables in your `.bashrc` file.
   `export AWS_ACCESS_KEY=<your_aws_access_key>`
   `export AWS_SECRET_KEY=<your_aws_secret_key>`
6. In the [Vagrantfile](Vagrantfile), Packer files [ops/site.json](ops/site.json) and [ops/consul.json](ops/consul.json), Terraform files [ops/terraform/variables.tf](ops/terraform/variables.tf) and [ops/terraform/terraform.tfvars](ops/terraform/terraform.tfvars) you need to replace all instances of `YOUR_ATLAS_USERNAME`, `YOUR_ATLAS_TOKEN`, `YOUR_AWS_ACCESS_KEY`, `YOUR_AWS_SECRET_KEY`, and `YOUR_ATLAS_ENVIRONMENT_NAME` with your Atlas username, Atlas token, [AWS Access Key Id, AWS Secret Access key](http://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSGettingStartedGuide/AWSCredentials.html), and desired Atlas environment name.

tl;dr Quick Steps
-----------------------------------------------
1. Run `packer push -create consul.json` in the [ops](ops) directory.
2. Navigate to "Variables" on the left sidebar of the "consul" build configuration (in [Builds tab](https://atlas.hashicorp.com/builds) of your Atlas account), then add the key `AWS_ACCESS_KEY` using your "AWS Access Key Id" as the value and the key `AWS_SECRET_KEY` using your "AWS Secret Access Key" as the value.
3. Navigate back to "Versions" on the left sidebar of the "consul" build configuration, then click "Rebuild" on the "consul" build configuration that errored. This one should succeed.
4. Run `packer push -create site.json` in the [ops](ops) directory.
5. Navigate to "Variables" on the left sidebar of the "metamon" build configuration, then add the key `AWS_ACCESS_KEY` using your "AWS Access Key Id" as the value and the key `AWS_SECRET_KEY` using your "AWS Secret Access Key" as the value.
6. Run `vagrant push` in the [root]() directory.
7. Navigate to "Links" on the left sidebar of the "metamon" build configuration, then complete the form with your Atlas username, `metamon` as the application name, and `/app` as the destination path.
8. Navigate back to "Versions" on the left sidebar of the "metamon" build configuration, then click "Rebuild" on the "metamon" build configuration that errored. This one should succeed.
9. Wait for both the “consul” and “metamon” builds to complete without errors
10. Run `terraform remote config -backend-config="name=YOUR_ATLAS_USERNAME/metamon"` in the [ops/terraform](ops/terraform) directory, replacing `YOUR_ATLAS_USERNAME` with your Atlas username.
11. Run `terraform apply` in the [ops/terraform](ops/terraform) directory.
12. Go the the public ip address of the newly created "metamon_1" box and you should see a web page that says "Hello, Atlas!".

Introduction and Configuring Metamon
-----------------------------------------------
Before jumping into configuration steps, it's helpful to have a mental model for how the Atlas workflow fits in.

Metamon's [motivation](https://github.com/tryolabs/metamon#motivation) is to make it dead simple to setup a standardized, automated, and generic environment using Ansible playbooks. Metamon will [provision a Vagrant box](https://github.com/tryolabs/metamon#features) to be a development ready web app using Django, Gunicorn, Nginx, and PostgreSQL. Take a look at the [Metamon repository](https://github.com/tryolabs/metamon) for more context on how the provisioning works.

The files in this repository are designed to make it just as simple to move from development to production by safely deploying and managing your infrastructure on AWS using the Atlas workflow. If you haven't deployed an app with [Atlas](https://atlas.hashicorp.com) before, we recommend you start with the [introductory tutorial](https://atlas.hashicorp.com/help/getting-started/getting-started-overview). Atlas by [HashiCorp](https://hashicorp.com) is a platform to develop, deploy, and maintain applications on any infrastructure provider.

Step 1: Build a Consul Server AMI
-------------------------
1. For Consul to work with this setup, we first need to create a Consul server AMI that will be used to build our Consul cluster. To do this, run `packer push -create consul.json` in the [ops](ops) directory. This will send the build configuration to Atlas so it can build your Consul server AMI remotely. You can follow [this walkthrough](https://github.com/hashicorp/atlas-examples/tree/master/consul) to get a better understanding of how we implemented this.
2. View the status of your build by going to the [Builds tab](https://atlas.hashicorp.com/builds) of your Atlas account and clicking on the "consul" build configuration. You will notice that the "consul" build errored immediately with the following error `Build 'amazon-ebs' errored: No valid AWS authentication found`. This is because we need to add our `AWS_ACCESS_KEY` and `AWS_SECRET_KEY` environment variables to the build configuration.
   ![Consul Build Configuration - Variables Error](screenshots/builds_consul_error_variables.png?raw=true)
3. Navigate to "Variables" on the left sidebar of the "consul" build configuration, then add the key `AWS_ACCESS_KEY` using your "AWS Access Key Id" as the value and the key `AWS_SECRET_KEY` using your "AWS Secret Access Key" as the value.
   ![Consul Build Configuration - Variables](screenshots/builds_variables.png?raw=true)
4. Navigate back to "Versions" on the left sidebar of the "consul" build configuration, then click "Rebuild" on the "consul" build configuration that errored. This one should succeed.
   ![Consul Build Configuration - Success](screenshots/builds_consul_success.png?raw=true)
5. This creates a fully-baked Consul server AMI that will be used for your Consul cluster.

Step 2: Build a Metamon AMI
-------------------------
1. Build an AMI using Metamon's Ansible provisioning that will create a functioning web app that uses Django, Gunicorn, Nginx, PostgreSQL and a few other [Metamon features](https://github.com/tryolabs/metamon#features). To do this, run `packer push -create site.json` in the [ops](ops) directory. This will send the build configuration to Atlas so it can build your Metamon AMI remotely.
2. View the status of your build by going to the [Builds tab](https://atlas.hashicorp.com/builds) of your Atlas account and clicking on the "metamon" build configuration. You will notice that the "metamon" build configuration errored immediately with the following error `* Bad source '/packer/app': stat /packer/app: no such file or directory`. This is because there is a [provisioner in the ops/site.json](ops/site.json#L65) Packer template that is expecting the application to already be linked. If you take that provisioner out, it would work, but you're just going to need it back in there after you link your application in the next step. This error is fine for now, we will be fixing this shortly.
   ![Metamon Build Configuration - Application Error](screenshots/builds_metamon_error_application.png?raw=true)
3. We also need to add our environment variables for the "metamon" build configuration so we don't get the same error we got with the "consul" build configuration. Navigate to "Variables" on the left sidebar of the "metamon" build configuration, then add the key `AWS_ACCESS_KEY` using your "AWS Access Key Id" as the value and the key `AWS_SECRET_KEY` using your "AWS Secret Access Key" as the value.
   ![Metamon Build Configuration - Variables](screenshots/builds_variables.png?raw=true)

Step 3: Link your Application Code
-------------------------
1. You'll now want to link up your actual Metamon application code to Atlas so that when you make any code changes, you can `vagrant push` them to Atlas and it will rebuild your AMI automatically. To do this, simply run `vagrant push` in the [root]() directory of your project where the Vagrant file is.
2. This will send your application code to Atlas, which is everything in the [app](app) directory. Link the "metamon" application and build configuration by clicking "Links" on the left sidebar of the "metamon" build configuration in the [Builds tab](https://atlas.hashicorp.com/builds) of your Atlas account. Complete the form with your Atlas username, `metamon` as the application name, and `/app` as the destination path.
   ![Metamon Build Configuration - Links](screenshots/builds_metamon_links.png?raw=true)
3. Now that your "metamon" application and build configuration are linked, navigate back to "Versions" on the left sidebar of the "metamon" build configuration, then click "Rebuild" on the "metamon" build configuration that errored. This one should succeed.
   ![Metamon Build Configuration - Success](screenshots/builds_metamon_success.png?raw=true)
4. This creates a fully-baked Django web app AMI that uses Consul for service discovery/configuration and health checking.

_\** `packer push site.json` will rebuild the AMI with the application code that was last pushed to Atlas whereas `vagrant push` will push your latest application code to Atlas and THEN rebuild the AMI. When you want any new modifications of your application code to be included in the AMI, do a `vagrant push`, otherwise if you're just updating the packer template and no application code has changed, do a `packer push site.json`._

Step 4: Deploy Metamon Web App and Consul Cluster
--------------------------
1. Wait for both the “consul” and “metamon” builds to complete without errors
2. Run `terraform remote config -backend-config="name=YOUR_ATLAS_USERNAME/metamon"` in the [ops/terraform](ops/terraform) directory, replacing `YOUR_ATLAS_USERNAME` with your Atlas username, to configure [remote state storage](https://www.terraform.io/docs/commands/remote-config.html) for this infrastructure. Now when you run Terraform, the infrastructure state will be saved in Atlas. This keeps a versioned history of your infrastructure.
3. Run `terraform apply` in the [ops/terraform](ops/terraform) directory to deploy your Metamon web app and Consul cluster.
4. You should see 2 new boxes spinning up in EC2, one named "metamon_1" which is your web app, and one named "consul_1" which is your Consul cluster.
   ![AWS - Success](screenshots/aws_success.png?raw=true)
5. Go to the "metamon" environment in the [Environments tab](https://atlas.hashicorp.com/environments) of your Atlas account and you'll now see the real-time health of all your nodes and services!
   ![Metamon Status](screenshots/environments_metamon_status.png?raw=true)

Final Step: Verify it Worked!
------------------------
1. Once the "metamon_1" box is running, go to its public ip and you should see a website that reads "Hello, Atlas!"
   ![Hello, Atlas!](screenshots/hello_atlas.png?raw=true)
2. Change your app code by modifying [app/app/views.py](app/app/views.py#L6) to say "Hello, World!" instead of "Hello, Atlas!".
3. Run `vagrant push` in your projects [root]() directory (where the Vagrantfile is). Once the packer build finishes creating the new AMI (view this in [Builds tab](https://atlas.hashicorp.com/builds) of your Atlas account), run `terraform apply` in the [ops/terraform](ops/terraform) directory and your newly updated web app will be deployed!

_\** One thing to note... Because your Django web app and PostgreSQL are running on the same box, anytime you rebuild that AMI and deploy, it's going to destroy the instance and create a new one - effectively destroying all of your data._

Cleanup
------------------------
1. Run `terraform destroy` to tear down any infrastructure you created. If you want to bring it back up, simply run `terraform apply` and it will bring your infrastructure back to the state it was last at.

