#!/bin/bash

export DIR=/home/$USER/kube_cluster_prep && \
export NODES_FILE=$DIR/nodesfile && \
export PROM_NODE=$(tail -1 $NODES_FILE |  cut -d "." -f 1)
