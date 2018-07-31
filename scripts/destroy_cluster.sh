#!/bin/bash
CLUSTER_NAME=${CLUSTER_NAME:=test-cluster}
ZONE=${ZONE:=us-east1-c}
MACHINE_TYPE=${MACHINE_TYPE:='n1-standard-1'}
NODE_COUNT=${NODE_COUNT:=3}

# Create the cluster.
gcloud beta container clusters delete "$CLUSTER_NAME" --zone "$ZONE"
