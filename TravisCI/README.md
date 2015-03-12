Configure Travis CI to push application code to ATLAS
===================
This repository and walkthrough guides you through configuring Travis CI to push application code to ATLAS on successful build.


Introduction and Configuring TRAVIS
------------------------------------
This guide assumes you know how to deploy a simple getting-started application on ATLAS and link the corresponding infrastructure, for more information see [Getting Started Guide](https://atlas.hashicorp.com/help/getting-started/getting-started-overview)

After you have successfully deployed the getting started application, there is always a need for continuous delivery of latest application code, in most of the cases whenever the code is pushed to master branch or after a successful build on Travis CI. The application code on ATLAS needs to be updated and we achieve this by pushing the latest code to ATLAS using the [atlas-upload-cli](https://github.com/hashicorp/atlas-upload-cli)

The atlas-upload-cli uses `ATLAS_TOKEN` as an environment variable for authentication and application code can be pushed using `atlas-upload <username>/app /path/to/app`.
`<username>` here is your username for ATLAS account and not the GitHub one.

Instructions for writing .travis.yml file
------------------------------------------

Step 1: Encrypt ATLAS Token
----------------------------
Since atlas-upload-cli uses `ATLAS_TOKEN` as an environment variable, this needs to be encrypted to be used in Travis CI. Travis provides a default method to encrypt keys so that they can be used as environment variables. For more information see [Encryption keys](http://docs.travis-ci.com/user/encryption-keys/).

```
gem install travis
travis encrypt ATLAS_TOKEN="YOUR_ATLAS_TOKEN"
```
This will output a string looking something like:
```
secure: ".... encrypted data ...."
```
Now you can place it in the `.travis.yml` file.

Step 2: Download and build atlas-upload-cli
-------------------------------------------
We will be building `atlas-upload-cli` from its `go` source in this example  like:

```
after_success:
    - echo "Build Successful"
    - sudo apt-get -y install golang
    - mkdir -p $PROJECT_ROOT/mygo
    - export GOPATH=$PROJECT_ROOT/mygo
    - go get github.com/hashicorp/atlas-upload-cli
    - cd $GOPATH/src/github.com/hashicorp/atlas-upload-cli/
    - make

```

Step 3: Push application code to ATLAS on successful build
---------------------
Depending on the requirements of your continous deployment architecture you can configure TRAVIS to push code. Here we will show how to push code to ATLAS which has been succesfully build by Travis after commiting to `master` branch. More information for configuring build can be found in [Travis Documentation](http://docs.travis-ci.com/user/build-configuration/).

```
branches:
    only:
    - master
```

Replace the `<username>` and app with your ATLAS username and application name in push command.
```
- ./bin/atlas-upload <username>/app $PROJECT_ROOT/app
```

The final `.travis.yml` would look like:
```
env:
    global:
        - PROJECT_ROOT=`pwd`
        - secure: ".... encrypted data ...."


before_install:
    - sudo apt-get -y update
    - echo "Update packages and configuration."

install:
    - echo "Install Build Dependencies Here"


before_script:
    - echo "Navigate to Test Suite"


script:
    - echo "Run Tests Here"


after_success:
    - echo "Build Successful"
    - sudo apt-get -y install golang
    - mkdir -p $PROJECT_ROOT/mygo
    - export GOPATH=$PROJECT_ROOT/mygo
    - go get github.com/hashicorp/atlas-upload-cli
    - cd $GOPATH/src/github.com/hashicorp/atlas-upload-cli/
    - make
    - ./bin/atlas-upload <username>/app $PROJECT_ROOT/app

branches:
    only:
        - master
```

Final Step: See the latest code
--------------------------------
That's it ! You have finally linked Travis CI to ATLAS for continous delivery depending on your build configuration settings.
You can see the latest version of your application code by navigating to the application in [development tab](https://atlas.hashicorp.com/development).
