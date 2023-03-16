#!/bin/bash

export DIR=/home/$USER && \
export OAR_NODE_FILE=$DIR/nodes.txt && \
export PROM_NODE=$(tail -1 $OAR_NODE_FILE |  cut -d "." -f 1)
