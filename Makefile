APP_NAME ?= divvycloud
NAMESPACE ?= divvycloud
VALUES ?= values.yaml

plugins:: plugins/uninstall plugins/install 


.PHONY: crd/install
crd/install:
	kubectl create -f crd/app-crd.yaml --namespace ${NAMESPACE}  --validate=false

.PHONY: app/install-notiller
app/install-notiller:
	mkdir -p ./build
	helm template --name=$(APP_NAME) --namespace ${NAMESPACE} -f ${VALUES} divvycloud  > ./build/divvycloud.yaml
	kubectl apply --namespace ${NAMESPACE} -f ./build/divvycloud.yaml

.PHONY: app/install
app/install:
	helm install --name=$(APP_NAME) --namespace ${NAMESPACE} -f ${VALUES} divvycloud 

.PHONY: app/uninstall-notille
app/uninstall-notiller:
	kubectl delete --namespace ${NAMESPACE} -f ./build/divvycloud.yaml

.PHONY: app/uninstall
app/uninstall:
	helm delete $(APP_NAME) --purge

.PHONY: app/upgrade
app/upgrade:
	helm upgrade $(APP_NAME) divvycloud

.PHONY: app/restart
app/restart:
	kubectl get deployment --namespace ${NAMESPACE} | grep -i divvycloud | grep -v mysq | grep -v redis | cut -d ' ' -f1 | xargs kubectl scale deployment --replicas=0 --namespace ${NAMESPACE}
	kubectl get deployment --namespace ${NAMESPACE} | grep -i divvycloud | grep -v mysq | grep -v redis | cut -d ' ' -f1 | xargs kubectl scale deployment --replicas=2 --namespace ${NAMESPACE}

.PHONY: plugins/uninstall
plugins/uninstall:
	- kubectl delete secret divvycloud-plugins --namespace ${NAMESPACE}

.PHONY: plugins/install
plugins/install:
	mkdir -p .build/plugins/
	- ( cd plugins/ && zip -r ../.build/plugins/plugins.zip *)
	- kubectl delete secret divvycloud-plugins --namespace ${NAMESPACE}
	- kubectl create secret generic divvycloud-plugins --from-file=.build/plugins/plugins.zip --namespace ${NAMESPACE}

.PHONY: clean
clean:
	rm -rf .build/plugins
