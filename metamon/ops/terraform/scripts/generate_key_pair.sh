if [ -s "ssh_keys/$1-key.pem" ] && [ -s "ssh_keys/$1-key.pub" ]; then
    echo Using existing $1-key pair...
else
    echo No $1-key pair exists, generating new keys...
    rm -rf ssh_keys/$1-key.pem
    rm -rf ssh_keys/$1-key.pub
    openssl genrsa -out ssh_keys/$1-key.pem 1024
    chmod 400 ssh_keys/$1-key.pem
    ssh-keygen -y -f ssh_keys/$1-key.pem > ssh_keys/$1-key.pub
fi
