#/!/bin/sh
##### Just in case #####
#old_prom_node=$(grep '.grid5000.fr' $root_dir/conf/prometheus/local-storage.yaml | sed 's/[\t ]//g;s/-//')
#sed_str=$(echo s/"$old_prom_node"/"$prom_node"/g)


root_dir="/home/ggrabher/kube_cluster_prep"

##### Setup local storage #####
prom_node="$(tail -1 $root_dir/nodesfile).lyon.grid5000.fr"
sed_str=$(echo s/\-.*grid5000\.fr/- "$prom_node"/g)
sed -i "$sed_str" $root_dir/conf/volumes/local-pvs.yaml

kubectl apply -f $root_dir/conf/volumes/local-pvs.yaml
echo "Monitoring will be setup on $prom_node"


##### Pre setup #####
kubectl label nodes $prom_node kubernetes.io/e2e-az-name=e2e-az1
kubectl create namespace monitoring


##### Setup the Prometheus helm chart #####
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm upgrade --install kube-prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --values $root_dir/conf/prometheus/kube-prometheus-stack-values.yaml


##### Setup Jaeger and its dependencies #####
#kubectl get configmap kube-proxy -n kube-system -o yaml | \
#	sed -e "s/strictARP: false/strictARP: true" | \
#	kubectl apply -f - -n kube-system

#helm repo add jetstack https://charts.jetstack.io
#helm repo update
#helm install \
#	cert-manager jetstack/cert-manager \
#	--namespace cert-manager \
#	--create-namespace \
#	--version v1.6.3 \
#	--set installCRDs=true

#kubectl create -f $root_dir/conf/jaeger/jaeger-operator.yaml -n monitoring
#kubectl rollout status deployment jaeger-operator -n monitoring
#kubectl apply -f $root_dir/conf/jaeger/all-in-one-badger.yaml -n monitoring 


##### Setup Open Telemetry operator and collector helm charts #####
#helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
#helm repo update
#helm install \ 
#	--namespace monitoring \ 
#	opentelemetry-operator open-telemetry/opentelemetry-operator \
#	-f $root_dir/conf/opentelemetry/opentelemetry-operator.yaml
#helm install \ 
#	--namespace monitoring \ 
#	opentelemetry-collector open-telemetry/opentelemetry-collector \
#	-f $root_dir/conf/opentelemetry/opentelemetry-collector.yaml

#### ####
