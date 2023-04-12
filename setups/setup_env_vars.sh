#!/bin/bash

G5K_USER_NAME='ggrabher'
export DIR="/home/$G5K_USER_NAME" 
export PROM_DIR="$DIR/share"
export NODES_FILE="$DIR/debian11-kube-imgpack/nodesfile"
export PROM_NODE=$(tail -1 $NODES_FILE |  cut -d "." -f 1)
export PROM_NODE_NAME="$PROM_NODE.lyon.grid5000.fr"
