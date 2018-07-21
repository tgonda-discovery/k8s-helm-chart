
# Overview

DivvyCloud enforces security, compliance, and governance policy in your cloud and container based infrastructure.

Below you will find steps on how to deploy DivvyCloud to a Kubernetes cluster. 

# Installation

## Tool dependencies

- [docker](https://docs.docker.com/install/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [make](https://www.gnu.org/software/make/)


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

## Backup / Restore

MySQL dump and the MySQL client are used to backlup and restore a DivvyCloud database
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

## Upgrades

 Simply restart all containers , the latest image will pull automatically. Upgrade of database occures on boot.
 Please backup your database prior to upgrading

