#!/bin/bash

source env.sh
curl  https://api.grid5000.fr/stable/sites/lyon/jobs/$OAR_JOB_ID | python3 -c "import sys, json; nodes=json.load(sys.stdin)['assigned_nodes']; [print(e) for e in nodes]" > $DIR/kube_cluster_prep/nodesfile
kadeploy3 debian11-nfs -f $NODES_FILE -k $DIR/.ssh/id_rsa.pub
