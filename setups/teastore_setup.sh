#/!/bin/bash

dir="$DIR/kube_cluster_prep"
FRONTEND_NODE=$(sed '5!d' $NODES_FILE)
MIDDLE_NODE=$(sed '4!d' $NODES_FILE)
BACKEND_NODE=$(sed '3!d' $NODES_FILE)
FRONTEND_NODE_NAME="$FRONTEND_NODE.lyon.grid5000.fr"
MIDDLE_NODE_NAME="$MIDDLE_NODE.lyon.grid5000.fr"
BACKEND_NODE_NAME="$BACKEND_NODE.lyon.grid5000.fr"

##### Pre setup #####
# Label front, middle and back end nodes
kubectl label nodes $FRONTEND_NODE_NAME kubernetes.io/node-category=teastore-frontend
echo "TeaStore front end will be setup on $FRONTEND_NODE_NAME"

kubectl label nodes $MIDDLE_NODE_NAME kubernetes.io/node-category=teastore-middle
echo "TeaStore middle end will be setup on $MIDDLE_NODE_NAME"

kubectl label nodes $BACKEND_NODE_NAME kubernetes.io/node-category=teastore-backend
echo "TeaStore back end will be setup on $BACKEND_NODE_NAME"

# Create namespace with resource default limits and requests
kubectl create namespace big-limited
kubectl apply -f $dir/conf/limitrange/big-limit-range.yaml

##### Launch TeaStore #####
kubectl create -f $dir/conf/teastore/teastore-ribbon-with-affinity.yaml --namespace big-limited
kubectl rollout status deployment teastore-webui -n big-limited

host_name=$(kubectl get pod --selector 'run=teastore-webui' -n big-limited -o jsonpath='{.items[*].spec.nodeName}')
host_ip=$(kubectl get node $host_name -o jsonpath='{.status.addresses[0].address}')

echo "TeaStore accessible at http://$host_ip:30080/tools.descartes.teastore.webui/"

