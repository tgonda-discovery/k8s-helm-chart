
# Overview

DivvyCloud enforces security, compliance, and governance policy in your cloud and container based infrastructure.

Below you will find steps on how to deploy DivvyCloud to a Kubernetes cluster. 

# Installation

## Tool dependencies

- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [make](https://www.gnu.org/software/make/)
- [helm](https://helm.sh/)

## Pre-reqs

The below instructions assumes:

 - That you have a valid kube config file and uses the default context
 - Helm is installed and functional

### Helm
We have included some convience scripts for installing helm into a raw GKE cluster. 

If your cluster already has helm installed, you  only need to install the helm cli on your computer. 

For instructions please see the [Helm github](https://github.com/helm/helm)


## Installing DivvyCloud

### Values file

  The values.yaml file located in the divvycloud/ directory allows you to configure your deployment.
  Please see the comments in the values.yaml for further documentation. 

### Using External Database
  By default this deployment will use a contanerized version of MySQL and Redis. This is good for kicking the tires. 
  The containerized version of MySQL is an ephemeral version and *WILL LOOSE ALL DATA* if restated. 

#### Setting up external database
  For more information on this topic please see our [Docs](http://docs.divvycloud.com/latest/installation/legacy.html)
  
  DivvyCloud will look for and use two database schemas: 
    - divvy
    - divvykeys

  After these two schemas are created you will need to create and grant privileges to a MySQL user. Please see our [documentation](http://docs.divvycloud.com/latest/installation/legacy.html) for more information on how to create the proper database schemas and users

#### Updating the Values.conf file 

  To configure an external MySQL environment, please edit the Values.yaml file and uncommend/update the following values:
    - database_host
    - database_port
    - database_user
    - database_password 

### Using External Redis

  DivvyCloud can perform reasonably well using just the internal Redis container. However, for production environments we highly recommend 
  using an external redis system. 

#### Setting up external Redis 

  To configure an external Redis system, please edit the Values.yaml file and uncommend/update the following values:
    - redis_host

## Installation 

### Important note
  This helm chart uses the k8s Application resource type. 
  *Please ensure you run the make crd/install prior to installing DivvyCloud*

### Building and installing 
	Clone down this repository and use the following make commands:

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

