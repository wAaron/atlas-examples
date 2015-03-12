Configure Travis CI to push application code to Atlas
===
This repository and walkthrough guides you through configuring [Travis CI](https://travis-ci.com/) to push application code to Atlas.


Introduction and Configuring Travis CI
---
This walkthrough assumes you know how to deploy a simple application with Atlas. For more information see our [Getting Started Guide](https://atlas.hashicorp.com/help/getting-started/getting-started-overview)

By sending application code from Travis to Atlas, you can complete a full continuous delivery lifecycle. An example developer workflow could be `git merge master > automatically start Travis tests > automatically build new AMIs with Atlas > automatically deploy application with Atlas`. From a developer point of view, this integration automates the full build and deploy process. From an operator point of view, Atlas can be configured to accept code from any location, then provision and deploy a new application version.  

Travis is able to push application code to Atlas by using the [Atlas Upload CLI](https://github.com/hashicorp/atlas-upload-cli). This requires that you have an Atlas username and Atlas authorization token. Create an [Atlas account here](https://atlas.hashicorp.com/account/new?utm_source=github&utm_medium=examples&utm_campaign=lamp), and then generate an [Atlas token](https://atlas.hashicorp.com/settings/tokens).

Step 1: Encrypt Atlas Token
---
The Atlas Upload CLI uses an `ATLAS_TOKEN` as an environment variable for authorization. This needs to be encrypted to be used with Travis CI. For more information see the [encryption keys](http://docs.travis-ci.com/user/encryption-keys/) section of the Travis documentation.

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
---
We will be building `atlas-upload-cli` from its `go` source in this example:

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

Step 3: Push application code to Atlas on successful build of master
---
Replace the ATLAS_USERNAME and ATLAS_APP with your Atlas username and application name.

The final `.travis.yml` will look like:
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
    - ./bin/atlas-upload ATLAS_USERNAME/ATLAS_APP $PROJECT_ROOT/app

branches:
    only:
        - master
```

Final Step: See the latest code
--------------------------------
That's it! You have linked Travis CI to Atlas for continous delivery. You can see the latest version of your application by navigating to the application in [development tab](https://atlas.hashicorp.com/development).
