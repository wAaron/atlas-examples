sudo apt-get -y update

sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password password'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password password'
# Install requirements
sudo apt-get install -y -qq \
    mysql-server \

# consul config
echo '{"service": {"name": "database", "tags": ["mysql"]}}' \
    >/etc/consul.d/mysql.json
sudo cp /upstart/consul_client.conf /etc/init/consul.conf

# install consul template
# wget https://github.com/hashicorp/consul-template/releases/download/v0.6.5/consul-template_0.6.5_linux_amd64.tar.gz
# tar xzf consul-template_0.6.5_linux_amd64.tar.gz
# sudo mv consul-template_0.6.5_linux_amd64/consul-template /usr/bin
# sudo rmdir consul-template_0.6.5_linux_amd64

# mongo config
# sudo cp /templates/consul_template.conf /etc/init/consul_template.conf