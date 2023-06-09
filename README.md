# Reserving the machines
	$ oarsub -I -p [CLUSTER_NAME] -l host=[N_HOSTS],walltime=[PERIOD]  -t deploy
	or
	$ oarsub -p [CLUSTER_NAME] -l host=[N_HOSTS],walltime=[PERIOD] -r [YYYY-MM-DD HH:MM:SS] -t deploy

	$ kadeploy3 debian11-base -f $OAR_FILE_NODES -k ~/.ssh/id_rsa.pub

# Setting up the Kubernetes cluster
	
	$ ./prepare.sh

# Launching the cluster
	
	 ssh root@[MASTER_NODE]
	 kubeadm init --config kubeadm-config.yaml

	In the output of `kubeadm init` there will be a kubeadm join command, launch it on every desired worker node
	For example:
	 ssh root@[WORKER_NODE]
	 kubeadm join 172.16.52.5:6443 --token [TOKEN] \
	--discovery-token-ca-cert-hash sha256:[SHA256_HASH]

# Network add-on for Kubernetes
	Here we'll use Weave, but another one can be used.
	 
	 kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
	 export KUBECONFIG=/etc/kubernetes/admin.conf

# Launch monitoring setup
	
	 ssh root@[MASTER_NODE]
	 source PATH/TO/kube_cluster_prep/setups/setup_env_vars.sh
	 PATH/TO/kube_cluster_prep/setups/setup_monitoring.sh


# Istio mesh setup

	On master node download istio:

	```
		curl -L https://istio.io/downloadIstio | sh -
	```

	```
	export PATH="$PATH:/root/istio-1.17.2/bin"
	```


	```
	istioctl install -y \
					--set components.egressGateways[0].name=istio-egressgateway \
					--set components.egressGateways[0].enabled=true
	```

	```
	kubectl label namespace default istio-injection=enabled
	```

	Create TeaStore pod and the generator pods

	```
	kubectl create -f gen.yaml
	```

	then create the gateways:

	```
	kubectl apply -f teastore-gateway.yaml
	```

	```
	kubectl apply -f gen-gateway.yaml
	```

	Check that the configuration is correct:

	```
	istioctl analyze
	```

	Check the load balancer:

	```
	kubectl get svc istio-ingressgateway -n istio-system
	```

	if you have pending status in External IP field then export the following variables:

	```
	export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
	export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')

	export INGRESS_HOST=$(kubectl get po -l istio=ingressgateway -n istio-system -o jsonpath='{.items[0].status.hostIP}')

	export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT
	```

	```
	echo "http://$GATEWAY_URL/"
	```
