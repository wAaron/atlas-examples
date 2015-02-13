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
