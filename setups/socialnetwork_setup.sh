#/!/bin/bash

dir='/home/ggrabher/kube_cluster_prep/'

git clone https://github.com/delimitrou/DeathStarBench.git
cp $dir/conf/workload_generator/nginx-thrift-nodeport.yaml ./

helm install socialnetwork DeathStarBench/socialnetwork/helm-chart/socialnetwork/
kubectl rollout status deployment nginx-thrift
kubectl apply -f nginx-thrift-nodeport.yaml

host_name=$(kubectl get pod --selector 'app=nginx-thrift' -o jsonpath='{.items[*].spec.nodeName}')
host_ip=$(kubectl get node $host_name -o jsonpath='{.status.addresses[0].address}')

echo "Social network accessible at $host_ip:30080"
