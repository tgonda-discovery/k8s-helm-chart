# Overview

DivvyCloud enforces security, compliance, and governance policy in your cloud and container based infrastructure.

Below you will find steps on how to deploy DivvyCloud to a Kubernetes cluster. 

# Before you start

## Tool dependencies

- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [make](https://www.gnu.org/software/make/)
- [helm](https://helm.sh/)

## Pre-reqs

The below instructions assumes:

 - That you have a valid kube config file and uses the default context
 - Helm is installed and functional

### Helm
We have included some convience scripts for installing helm into a raw GKE cluster.  Please see the scripts directory.

If your cluster already has helm installed, you  only need to install the helm cli on your computer. 

For instructions please see the [Helm github](https://github.com/helm/helm)


# Quick Start

## Create GKE Cluster

If you do not have a cluster already, you can create one in GKE using our script

```
sh scripts/create_cluster.sh
```

## Install helm

In order to install DivvyCloud, helm must be installed on the cluster and on your machine. 

```
brew install helm
sh scripts/install_helm.sh
```

# Configuration 

## Values file

The values file has many configuration options. Please refer to the comments in the values.yaml file for further documentation.
  
### Using External Database

The values.yaml file located in the divvycloud/ directory allows you to configure your deployment.
By default this deployment will use a contanerized version of MySQL and Redis. This is good for kicking the tires, however is not recommended for production environments. 
The containerized version of MySQL is an ephemeral version and *WILL LOOSE ALL DATA* if restarted. 
  

#### Setup DB
DivvyCloud will look for and use two database schemas: 

- divvy
- divvykeys

After these two schemas are created you will need to create and grant privileges to a MySQL user. 
For more information on this topic please see our [Docs](http://docs.divvycloud.com/latest/installation/legacy.html)

#### Enable External Db support
  To enable External Database support, you will need to update the values.yaml and set the useExternalDb to true
  
  ```
  useExternalDb: true
  ```  

*IMORTANT NOTE: In the next steps you can uncomment either databaseHost or cloudSQLInstanceName , but not both. If you uncomment both the deployment will fail.*

##### Google CloudSQL

To use Google Cloud SQL, you will want to uncomment and update the following option in the values.yaml.

The CloudSQLInstanceName can be found on the database information page for the CloudSQL Instance you are using. Once you have the, update the values.yaml:

```
cloudSQLInstanceName: [Your_CloudSQLInstanceName_]
```

Next we need to create a GCP Service Account that has access to GoogleCloudSQL. Please follow steps *1-5.1* from the following instructions:

*There is no need to perform step 5.2  (cloudsql-db-credentials) , as we will use variables below to set username and password.*

[Google CloudSQL Documentation] (https://cloud.google.com/sql/docs/mysql/connect-kubernetes-engine)

#### Using Other MySQL instance (RDS / Native / etc..)

To use a standard MySQL instance or RDS, uncomment databaseHost in the values.yaml
```yaml
databaseHost: [IP_OR_HOSTNAME_OF_MYSQL_SERVER]
```

#### Database Username and password

Finally we need to update the database username and password values in the values.yaml
```yaml
databaseUser: [insert_username_here]
databasePassword: [insert_password_here]
```

# Installation 

Once you have modified the values.yml (optional), you can install DivvyCloud by running two commands:

```
make crd/install
make app/install 
```

## Important note

This helm chart uses the k8s Application resource type. 
*Please ensure you run the make crd/install prior to installing DivvyCloud*

### Installing 
Clone this repository and use the following make commands:

* make crd/install to install the application CRD on the cluster. This needs to be done only once.
* make app/install to build all the container images and deploy the app to a target namespace on the cluster.
* make app/uninstall to delete the deployed app.

## Connecting to admin console

By default DivvyCloud is only accessible from inside the kube cluster. As a result we must setup a port forward

```
kubectl port-forward svc/divvycloud-interfaceserver 8001

```

Next open http://localhost:8001/ in your web browser

## Upgrading 

  To upgrade simply pull the latest from this repository and then run:

  ```
  make app/upgrade
  ```
  

## Backup / Restore of internal MySQL

MySQL dump and the MySQL client are used to backlup and restore a DivvyCloud database.
First you need to get the IP address of the mysql service in your k8s deployment 

```
  MYSQL_IP=$(kubectl get \
    --namespace default \
    svc divvycloud-mysql\
    -o jsonpath='{.spec.clusterIP})

```

Next use the username and password
```
kubectl get secret divvycloud-secret -o jsonpath={'.data.DIVVY_MYSQL_USER'}  | base64 -D
kubectl get secret divvycloud-secret -o jsonpath={'.data.DIVVY_MYSQL_PASSWORD'}  | base64 -D
```

Finally to backup a database:
```
mysqldump -u [MYSQL_USER] -p -h [MYSQL_IP] divvy > divvy.sql
mysqldump -u [MYSQL_USER] -p -h [MYSQL_IP] divvykeys > divvykeys.sql
```

To restore a database:

```
mysql -u [MYSQL_USER] -p -h [MYSQL_IP] divvy < divvy.sql
mysql -u [MYSQL_USER] -p -h [MYSQL_IP] divvykeys < divvykeys.sql
```

