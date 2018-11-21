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

These commands require helm to be install locally. 
```
make crd/install
make app/install 
```



# Configuration 
## Configuration

**We look for values.yaml in the same directory as the Makefile.**

The following table lists the configurable parameters of the Redis chart and their default values.

| Parameter                                  | Description                                                                                                    | Default                                              |
|--------------------------------------------|----------------------------------------------------------------------------------------------------------------|------------------------------------------------------|
| `imageName`                     | Image Name | `divvycloud/divvycloud:latest`                                                |
| `mysqlInstance`                     | Image Name for MySQL db | `nil`                                                |
| `imagePullPolicy`                           | Image Pull Policy | `Always`                                          |
| `useExternalDb`                         | Use an external Database | `false`                                      |
| `cloudSQLInstanceName`                         | GoogleCloudSQL Instance Name. This cannot be used *with* databaseHost. If using CloudSQLInstance, please follow the directions below for adding a CloudInstnaceCreds json to kubernetes                                                                                               | `nil`                                      |
| `databaseHost`                         | Hostname/IP Address of MySQL Server. This cannot be used *with* cloudSQLInstanceName| `nil`                                      |
| `databasePort`                         | Database Port. Do not change if using Google CloudSQL | `3306`                                      |
| `databaseUser`                         | Username that has access to divvy/divvykeys schemas | `divvy`                                      |
| `databasePassword`                         | Password paired with above  MySQL username| `divvy`                                      |
| `pvcEnabled`                         | Use PVC storage for MySQL container (Not necessary if using external Db)| `true`                                      |
| `storageSize`                         | Size of PVC Storage | `30G`                                      |
| `enablePlugins`                         | Enable plugins| `false`                                      |
| `internalLoadBalancer`                         | Use GCE Internal load balancer | `true`                                      |
| `autoIngress`                         | Use auto-ingress (for Nginx Ingress) | `false`                                      |
| `httpProxy`                         | proxy addresses | `nil`                                      |
| `httpsProxy`                         | proxy addresses | `nil`                                      |
| `noProxy`                         | Addresses that will ignore proxy (if set)| `nil`                                      |
| `replicaCounts.harvesters`                         | Number of harvesters | `2`                                      |
| `replicaCounts.interfaceservers`                         | Number of interface servers | `2`                                      |
| `replicaCounts.schedulers`                         | Number of schedules | `2`                                      |
| `replicaCounts.processors`                         | Number of processors | `2`                                      |
| `replicaCounts.ondemands`                         | Number of on-demand workers | `2`                                      |


# Make Commands 

| Parameter                                  | Description                                                                                                    
|--------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------|
| `make crd/install`                     | Install Application CRD REQUIRED |
| `make app/install`                     | Install DivvyCloud using tiller |
| `make app/install-notiller`                     | Install DivvyCloud using helm template and deploy with kubectl -f apply  | 
| `make app/uninstall`                     | Uninstall DivvyCloud using tiller | 
| `make app/uninstall-notiller`                     | Install DivvyCloud using helm template and kubectl  |
| `make app/restart`                     | Restart the DivvyCloud suite |
| `make plugins/install`                     | Upload plugins to kubectl. Place all plugins in ./plugins/ directory prior to running this command. Suite restart is required after deployment. enablePlugins must be true (see above configuration) |
| `make plugins/uninstall`                     | Remove uploaded plugins |


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

##### Google CloudSQL

To use Google Cloud SQL, you will want to uncomment and update the following option in the values.yaml.

The CloudSQLInstanceName can be found on the database information page for the CloudSQL Instance you are using. Once you have the, update the values.yaml:

```
cloudSQLInstanceName: [Your_CloudSQLInstanceName_]
```

You must also upload a your cloudsql instance credentials (Aka ServiceAccount JSON) to kubernetes. Once a CloudSQLInstance has been provisioned and a service account created, run the following command:

```
kubectl create secret generic cloudsql-instance-credentials --namespace divvycloud\
    --from-file=credentials.json=[path to json file created for service account]
```

Information for creating a GCP Service Account that has access to GoogleCloudSQL please read the following instructions. Please follow steps *1-5.1* from the following instructions:

[Google CloudSQL Documentation] (https://cloud.google.com/sql/docs/mysql/connect-kubernetes-engine)

*There is no need to perform step 5.2  (cloudsql-db-credentials) , as we will use variables below to set username and password.*

# Installation 

Once you have modified the values.yml (optional), you can install DivvyCloud by running two commands:

```
make crd/install
make app/install 
```

## Connecting to admin console

By default DivvyCloud is only accessible from inside the kube cluster. As a result we must setup a port forward

```
kubectl port-forward svc/divvycloud-interfaceserver 8001

```
Next open http://localhost:8001/ in your web browser


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

