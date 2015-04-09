#!/bin/sh

if [ -f "terraform/ssh_keys/consul-key.pem" ] && [ -f "terraform/ssh_keys/consul-key.pub" ]; then
    echo Using existing consul-key pair...
else
    echo No consul-key pair exists, generating new keys...
    find terraform/ssh_keys -type f -delete
    openssl genrsa -out terraform/ssh_keys/consul-key.pem 1024
    chmod 400 terraform/ssh_keys/consul-key.pem
    ssh-keygen -y -f terraform/ssh_keys/consul-key.pem > terraform/ssh_keys/consul-key.pub
fi

