echo Copying Consul server config into upstart...
echo '{"service": {"name": "consul", "tags": ["consul", "server", "bootstrap"]}}' \
        >/etc/consul.d/bootstrap.json
sudo cp /ops/upstart/consul_server.conf /etc/init/consul.conf
