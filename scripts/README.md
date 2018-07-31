# Helm scripts 

    This script will install helm on a newly created kube cluster 
    It presumes you have installed the helm CLI locally. Please see [Helm Github](https://github.com/helm/helm)

# Cluster scripts

These scripts are intended to help with easily creating and destroying GKE clusters. 

## Variables

These scripts will use your gcloud cli to create and destory clusters. Variables can be supplied , but are not required.
The following environment variables are looked for by the scripts:

CLUSTER_NAME=YouClusterName
ZONE=us-east1-c
MACHINE_TYPE=n1-standard-1
NODE_COUNT=3


## Create cluster 

sh ./create_cluster.sh


## Destroy clusters

sh ./destroy_cluster.sh
