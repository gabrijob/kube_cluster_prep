#/!/bin/sh

root_dir="$DIR/kube_cluster_prep"

##### Setup local storage #####
sed_str=$(echo s/PROM_NODE_NAME/\""$PROM_NODE_NAME"\"/g)
sed -i "$sed_str" $root_dir/conf/volumes/local-pvs.yaml
sed_str=$(echo s/LOCAL_DIR_PATH/\""${PROM_DIR//\//\\\/}"\"/g)
sed -i "$sed_str" $root_dir/conf/volumes/local-pvs.yaml

kubectl apply -f $root_dir/conf/volumes/local-pvs.yaml
echo "Monitoring will be setup on $PROM_NODE"

sed_str=$(echo s/\""$PROM_NODE_NAME"\"/PROM_NODE_NAME/g)
sed -i "$sed_str" $root_dir/conf/volumes/local-pvs.yaml
sed_str=$(echo s/\""${PROM_DIR//\//\\\/}"\"/LOCAL_DIR_PATH/g)
sed -i "$sed_str" $root_dir/conf/volumes/local-pvs.yaml


##### Pre setup #####
kubectl label nodes $PROM_NODE_NAME kubernetes.io/e2e-az-name=e2e-az1
kubectl create namespace monitoring


##### Setup the Prometheus helm chart #####
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install kube-prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --values $root_dir/conf/prometheus/kube-prometheus-stack-values.yaml  --no-hooks


#### ####
