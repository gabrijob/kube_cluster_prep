#/!/bin/bash

dist=$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '""')

sudo apt-get remove -y docker docker-engine docker.io containerd runc

sudo apt-get update
sudo apt-get install -y ca-certificate curl gnupg lsb-release

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/$dist/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

arch=$(dpkg --print-architecture)
release=$(lsb_release -cs)
echo "deb [arch=$arch signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$dist $release stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
#sudo apt-get install -y docker.io
#systemctl start docker
#systemctl enable docker
sudo service docker start

# Post-installation steps
sudo groupadd docker
sudo usermod -aG docker $USER
