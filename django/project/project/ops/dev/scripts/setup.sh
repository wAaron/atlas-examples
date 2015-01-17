sudo apt-get -y update
sudo apt-get -y install python-dev python-pip
sudo apt-get -y install python-pip
sudo pip install Django

# Automatically cd into /vagrant
touch /home/vagrant/.profile
grep -q 'cd /vagrant' /home/vagrant/.profile || {
  echo 'cd /vagrant' >> /home/vagrant/.profile
}