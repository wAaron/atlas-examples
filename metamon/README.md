Metamon
===================
This repository and walkthrough guides you through deploying the [Metamon Project](https://github.com/tryolabs/metamon) via Atlas on AWS.

General setup
-------------
1. Download and install [Virtualbox](https://www.virtualbox.org/wiki/Downloads), [Vagrant](https://www.vagrantup.com/downloads.html), [Packer](https://www.packer.io/downloads.html), and [Terraform](https://www.terraform.io/downloads.html)
2. Clone this repository
3. Create an [Atlas account](https://atlas.hashicorp.com/account/new?utm_source=github&utm_medium=examples&utm_campaign=metamon) and save your Atlas username as an environment variable
  1. `$ export ATLAS_USERNAME=<your_atlas_username>`
4. Generate an [Atlas token](https://atlas.hashicorp.com/settings/tokens) and save as an environment variable
  1. `$ export ATLAS_TOKEN=<your_atlas_token>`
5. Get your [AWS access and secret keys](http://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSGettingStartedGuide/AWSCredentials.html) and save as environment variables
  1. `$ export AWS_ACCESS_KEY=<your_aws_access_key>`
  2. `$ export AWS_SECRET_KEY=<your_aws_secret_key>`
6. In the [Vagrantfile](https://github.com/hashicorp/atlas-examples/tree/master/metamon/Vagrantfile), Packer files [ops/site.json](https://github.com/hashicorp/atlas-examples/tree/master/metamon/ops/site.json) and [ops/consul.json](https://github.com/hashicorp/atlas-examples/tree/master/metamon/ops/consul.json), Terraform files [ops/terraform/variables.tf](https://github.com/hashicorp/atlas-examples/tree/master/metamon/ops/terraform/variables.tf) and [ops/terraform/terraform.tfvars](https://github.com/hashicorp/atlas-examples/tree/master/metamon/ops/terraform/terraform.tfvars), and Consul upstart scripts [ops/upstart/consul_client.conf](https://github.com/hashicorp/atlas-examples/tree/master/metamon/ops/upstart/consul_client.conf) and [ops/upstart/consul_server.conf](https://github.com/hashicorp/atlas-examples/tree/master/metamon/ops/upstart/consul_server.conf) you need to replace all instances of `YOUR_ATLAS_USERNAME`, `YOUR_ATLAS_TOKEN`, `YOUR_AWS_ACCESS_KEY`, `YOUR_AWS_SECRET_KEY`, and `YOUR_AWS_KEY_PAIR_NAME` with your Atlas username, Atlas token, [AWS Access Key Id, AWS Secret Access key](http://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSGettingStartedGuide/AWSCredentials.html), and [AWS key pair name](http://docs.aws.amazon.com/gettingstarted/latest/wah/getting-started-prereq.html)

tl;dr
-----------------------------------------------
1. Run `packer push -create consul.json` in the [ops](https://github.com/hashicorp/atlas-examples/tree/master/metamon/ops) directory
2. Run `packer push -create site.json` in the [ops](https://github.com/hashicorp/atlas-examples/tree/master/metamon/ops) directory
3. Run `vagrant push` in the [root](https://github.com/hashicorp/atlas-examples/tree/master/metamon) directory
4. Navigate to "Links" in the left navigation of the "metamon" build configuration (in [Builds tab](https://atlas.hashicorp.com/builds) of your Atlas account), then complete the form with your Atlas username, `metamon` as the application name, and `/app` as the destination path.
5. Run `terraform apply` in the [ops/terraform](https://github.com/hashicorp/atlas-examples/tree/master/metamon/ops/terraform) directory
6. Go the the public ip address of the newly created "metamon_1" box and you should see a web page that says "Hello, Atlas!"

Introduction and Configuring Metamon
-----------------------------------------------
Before jumping into configuration steps, it's helpful to have a mental model for how the Atlas workflow fits in.

Metamon's [motivation](https://github.com/tryolabs/metamon#motivation) is to make it dead simple to setup a standardized, automated, and generic environment using Ansible playbooks. Metamon will [provision a Vagrant box](https://github.com/tryolabs/metamon#features) to be a development ready web app using Django, Gunicorn, Nginx, and PostgreSQL. Take a look at the [Metamon repository](https://github.com/tryolabs/metamon) for more context on how the provisioning works.

The files in this repository are designed to make it just as simple to move from development to production by safely deploying and managing your infrastructure on AWS using the Atlas workflow. If you haven't deployed an app with [Atlas](https://atlas.hashicorp.com) before, we recommend you start with the [introductory tutorial](https://atlas.hashicorp.com/help/getting-started/getting-started-overview). Atlas by [HashiCorp](https://hashicorp.com) is a platform to develop, deploy, and maintain applications on any infrastructure provider.

Step 1: Build a Consul Server AMI
-------------------------
1. For Consul to work with this setup, we first need to create a Consul server AMI that will be used to build our Consul cluster. To do this, run `packer push -create consul.json` in the [ops](https://github.com/hashicorp/atlas-examples/tree/master/metamon/ops) directory. This will send the build configuration to Atlas so it can build your Consul server AMI remotely. You can follow [this walkthrough](https://github.com/hashicorp/atlas-examples/tree/master/consul) to get a better understanding of how we implemented this. We generally recommend at least a 3 node Consul cluster, but for this example we are just creating 1.
2. View the status of your build by going to the [Builds tab](https://atlas.hashicorp.com/builds) of your Atlas account and clicking on the "consul" build configuration.
  1. ![Builds](screenshots/builds.png?raw=true)
  2. ![Consul Build Configuration](screenshots/consul_build_conf.png?raw=true)

Step 2: Build a Metamon AMI
-------------------------
1. Build an AMI using Metamon's Ansible provisioning that will create a functioning web app using Django, Gunicorn, Nginx, PostgreSQL and a few other [Metamon features](https://github.com/tryolabs/metamon#features). To do this, run `packer push -create site.json` in the [ops](https://github.com/hashicorp/atlas-examples/tree/master/metamon/ops) directory. This will send the build configuration to Atlas so it can build your Metamon AMI remotely.
2. View the status of your build by going to the [Builds tab](https://atlas.hashicorp.com/builds) of your Atlas account and clicking on the "metamon" build configuration.
  1. ![Builds](screenshots/builds.png?raw=true)
  2. ![Metamon Build Configuration](screenshots/metamon_build_conf.png?raw=true)
3. This creates an AMI with a functioning Django web app that uses Consul for service discovery/configuration and health checking.

_\** The Packer build will fail saying `* Bad source '/packer/app': stat /packer/app: no such file or directory
` until you complete the next step as there is a [provisioner](https://github.com/hashicorp/atlas-examples/tree/master/metamon/ops/site.json#L65) in the [ops/site.json](https://github.com/hashicorp/atlas-examples/tree/master/metamon/ops/site.json) Packer template that is expecting the application to already be linked. If you take that provisioner out, it would work, but you're just going to need it back in there after you link your application in the next step._

Step 3: Link your application code
-------------------------
1. You'll now want to link up your actual Metamon application code to Atlas so that when you make any code changes, you can `vagrant push` them to Atlas and it will rebuild your AMI automatically. To do this, simply run `vagrant push` in the [root](https://github.com/hashicorp/atlas-examples/tree/master/metamon) directory of your project where the Vagrant file is. This will send your Metamon application code to Atlas, which is everything in [/app](https://github.com/hashicorp/atlas-examples/tree/master/metamon/app). Then, link the metamon application with your metamon build configuration by clicking on your metamon build configuration under the [Builds tab](https://atlas.hashicorp.com/builds) of your Atlas account, then "Links" in the left navigation. Complete the form with your Atlas username, `metamon` as the application name, and `/app` as the destination path.
  1. ![Links](screenshots/links.png?raw=true)
2. Now that your application and metamon build configuration are linked, click "Rebuild" on the latest metamon build configuration in the [Builds tab](https://atlas.hashicorp.com/builds) of your Atlas account and you will have a fully-baked AMI of your Django web app.
  1. ![Rebuild](screenshots/links.png?raw=true)

_\** `packer push site.json` will rebuild the AMI with the application code that was last pushed to Atlas whereas `vagrant push` will push your latest application code to Atlas and THEN rebuild the AMI. When you want any new modifications of your application code to be included in the AMI, do a `vagrant push`, otherwise if you're just updating the packer template but no application code has changed, do a `packer push site.json`._

Step 4: Deploy Metamon Web App and Consul Cluster
--------------------------
1. To deploy your Metamon web app and Consul cluster, all you need to do is run `terraform apply` in the [ops/terraform](https://github.com/hashicorp/atlas-examples/tree/master/metamon/ops/terraform) directory.
2. You should see 2 new boxes spinning up in EC2, one named metamon_1 which is your web app, and one named consul_1 which is your Consul cluster (of 1 for now).
  1. ![AWS](screenshots/aws_ec2_instances.png?raw=true)

Final Step: Test Metamon
------------------------
1. Once the metamon_1 box is running, go to its public ip and you should see a website that reads "Hello, Atlas!"
  1. ![Hello, Atlas!](screenshots/hello_atlas.png?raw=true)
2. Navigate to the [Environments tab](https://atlas.hashicorp.com/environment) of your Atlas account and click on the newly created "metamon" environment. You'll now see the real-time health of all your nodes and services!
  1. ![Environments](screenshots/environments.png?raw=true)
  2. ![Metamon Infrastructure](screenshots/metamon_infrastructure.png?raw=true)
3. Change your app code by modifying [/app/app/views.py](https://github.com/hashicorp/atlas-examples/tree/master/metamon/app/app/views.py) to say "Hello, World!" instead of "Hello, Atlas!".
4. Run `vagrant push` in your projects root directory (where the Vagrantfile is). Once the packer build finishes (view this in [Builds tab](https://atlas.hashicorp.com/builds) of your Atlas account), run `terraform apply` in the [ops/terraform](https://github.com/hashicorp/atlas-examples/tree/master/metamon/ops/terraform) directory and your new web app will be deployed!

Cleanup
------------------------
1. Run `terraform destroy` to tear down any infrastructure you created. If you want to bring it back up, simply run `terraform apply` and it will bring your infrastructure back to the state it was last at.

