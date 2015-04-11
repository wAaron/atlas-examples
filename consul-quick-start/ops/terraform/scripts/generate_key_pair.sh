if [ -s "ssh_keys/consul-key.pem" ] && [ -s "ssh_keys/consul-key.pub" ]; then
    echo Using existing consul-key pair...
else
    echo No consul-key pair exists, generating new keys...
    find ssh_keys -type f -delete
    openssl genrsa -out ssh_keys/consul-key.pem 1024
    chmod 400 ssh_keys/consul-key.pem
    ssh-keygen -y -f ssh_keys/consul-key.pem > ssh_keys/consul-key.pub
    echo ssh_keys/consul-key.pem contents...
    cat ssh_keys/consul-key.pem
    echo ssh_keys/consul-key.pub contents...
    cat ssh_keys/consul-key.pub
fi