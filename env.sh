#!/bin/bash

export DIR=/home/$USER && export PROM_NODE=$(tail -1 $DIR/nodes.txt |  cut -d "." -f 1)
