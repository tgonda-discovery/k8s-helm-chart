APP_NAME ?= divvycloud
NAMESPACE ?= divvycloud

plugins:: plugins/uninstall plugins/install 

.PHONY: crd/install
crd/install:
	kubectl create -f crd/app-crd.yaml

.PHONY: app/install
app/install:
	helm install --name=$(APP_NAME) --namespace ${NAMESPACE} divvycloud

.PHONY: app/uninstall
app/uninstall:
	helm delete $(APP_NAME) --purge

.PHONY: app/upgrade
app/upgrade:
	helm upgrade $(APP_NAME) divvycloud

.PHONY: app/restart
app/restart:
	kubectl get deployment | grep -i divvycloud | grep -v mysq | grep -v redis | cut -d ' ' -f1 | xargs kubectl scale deployment --replicas=0
	kubectl get deployment | grep -i divvycloud | grep -v mysq | grep -v redis | cut -d ' ' -f1 | xargs kubectl scale deployment --replicas=2

.PHONY: plugins/uninstall
plugins/uninstall:
	- kubectl delete secret divvycloud-plugins

.PHONY: plugins/install
plugins/install:
	mkdir -p .build/plugins/
	- ( cd plugins/ && zip -r ../.build/plugins/plugins.zip *)
	- kubectl delete secret divvycloud-plugins
	- kubectl create secret generic divvycloud-plugins --from-file=.build/plugins/plugins.zip

.PHONY: clean
clean:
	rm -rf .build/plugins
