sudo apt-get -y update
sudo apt-get -y install curl

# Setup a proper node PPA
sudo curl -sL https://deb.nodesource.com/setup | sudo bash -

# Install requirements
sudo apt-get install -y -qq \
    nodejs

# node upstart
sudo cp /ops/upstart/nodejs.conf /etc/init/nodejs.conf

# consul config
echo '{"service": {"name": "web", "port": 8888, "tags": ["nodejs"]}}' \
    >/etc/consul.d/node.json
sudo cp /ops/upstart/consul_client.conf /etc/init/consul.conf