#/!/bin/bash

dir='/home/ggrabher/kube_cluster_prep/'

git clone https://github.com/DescartesResearch/TeaStore.git
kubectl create -f https://raw.githubusercontent.com/DescartesResearch/TeaStore/master/examples/kubernetes/teastore-ribbon.yaml
kubectl rollout status deployment teastore-webui

host_name=$(kubectl get pod --selector 'app=teastore-webui' -o jsonpath='{.items[*].spec.nodeName}')
host_ip=$(kubectl get node $host_name -o jsonpath='{.status.addresses[0].address}')

echo "TeaStore accessible at http://$host_ip:30080/tools.descartes.teastore.webui/"

