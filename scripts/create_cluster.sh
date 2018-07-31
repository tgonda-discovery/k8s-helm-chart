#!/bin/bash
CLUSTER_NAME=${CLUSTER_NAME:=test-cluster}
ZONE=${ZONE:=us-east1-c}
MACHINE_TYPE=${MACHINE_TYPE:='n1-standard-1'}
NODE_COUNT=${NODE_COUNT:=3}

# Create the cluster.
gcloud beta container clusters create "$CLUSTER_NAME" \
    --zone "$ZONE" \
    --machine-type $MACHINE_TYPE \
    --num-nodes "$NODE_COUNT"

# Configure kubectl authorization.
gcloud container clusters get-credentials "$CLUSTER_NAME" --zone "$ZONE"

# Bootstrap RBAC cluster-admin for your user.
# More info: https://cloud.google.com/kubernetes-engine/docs/how-to/role-based-access-control
kubectl create clusterrolebinding cluster-admin-binding \
  --clusterrole cluster-admin --user $(gcloud config get-value account)
