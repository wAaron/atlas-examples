if [ -s "ssh_keys/$1-key-pair-$2.pem" ] && [ -s "ssh_keys/$1-key-pair-$2.pub" ]; then
    echo Using existing $1-key-pair-$2 pair...
else
    echo $1-key-pair-$2 does not exist, generating new keys...
    rm -rf ssh_keys/$1-key-pair-$2.pem
    rm -rf ssh_keys/$1-key-pair-$2.pub
    openssl genrsa -out ssh_keys/$1-key-pair-$2.pem 1024
    chmod 400 ssh_keys/$1-key-pair-$2.pem
    ssh-keygen -y -f ssh_keys/$1-key-pair-$2.pem > ssh_keys/$1-key-pair-$2.pub
    echo ssh_keys/$1-key-pair-$2.pem contents...
    cat ssh_keys/$1-key-pair-$2.pem
    echo ssh_keys/$1-key-pair-$2.pub contents...
    cat ssh_keys/$1-key-pair-$2.pub
fi
