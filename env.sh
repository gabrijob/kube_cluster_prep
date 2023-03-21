#!/bin/bash

export DIR=/home/$USER && \
export NODES_FILE=$DIR/kube_cluster_prep/nodesfile && \
export PROM_NODE=$(tail -1 $NODES_FILE |  cut -d "." -f 1)
