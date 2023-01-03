#/!/bin/sh
##### Just in case #####
#old_prom_node=$(grep '.grid5000.fr' $root_dir/conf/prometheus/local-storage.yaml | sed 's/[\t ]//g;s/-//')
#sed_str=$(echo s/"$old_prom_node"/"$prom_node"/g)


root_dir="/home/ggrabher/kube_cluster_prep"

##### Setup local storage for Prometheus #####
prom_node="$(tail -1 $root_dir/nodesfile).lyon.grid5000.fr"
sed_str=$(echo s/\-.*grid5000\.fr/- "$prom_node"/g)
sed -i "$sed_str" $root_dir/conf/volumes/local-pvs.yaml

kubectl apply -f $root_dir/conf/volumes/local-pvs.yaml
echo "Prometheus will be setup on $prom_node"


##### Setup the Prometheus helm chart #####
kubectl label nodes $prom_node kubernetes.io/e2e-az-name=e2e-az1

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
kubectl create namespace monitoring
helm upgrade --install kube-prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --values $root_dir/conf/prometheus/kube-prometheus-values.yaml
