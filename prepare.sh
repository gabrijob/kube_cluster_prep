#/!/bin/bash

#Load conf files
source ./utils.sh

dir=$(pwd)
filename="nodesfile" 

rm nodesfile*

#Creating node file through of G5K reservation
discovery-cluster $filename $dir

update-local-key  $filename $dir

# Setup all dependencies for helm and kubernetes
for i in $(cat ${filename}); do 
	ssh-copy-id $USER@$i
	ssh root@$i 'bash -s' < setups/dependencies_setup.sh
	ssh root@$i 'bash -s' < setups/docker_setup.sh
	ssh root@$i 'bash -s' < setups/containerd_setup.sh
	ssh root@$i 'bash -s' < setups/kubernetes_setup.sh
	ssh root@$i 'bash -s' < setups/helm_setup.sh
	scp kubeadm-config.yaml root@$i: 
	ssh root@$i 'swapoff -a'
#	ssh root@$i 'kubeadm init --config kubeadm-config.yaml'
done
