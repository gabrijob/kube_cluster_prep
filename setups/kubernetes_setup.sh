#/!/bin/bash

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

sudo curl  -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb [trusted=yes] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet=1.26.2-00 kubeadm=1.26.2-00 kubectl=1.26.2-00
sudo apt-mark hold kubelet kubeadm kubectl
