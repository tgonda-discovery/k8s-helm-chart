APP_NAME ?= divvycloud

.PHONY: crd/install
crd/install:
	kubectl create -f crd/app-crd.yaml

.PHONY: app/install
app/install:
	helm install --name=$(APP_NAME) divvycloud

.PHONY: app/uninstall
app/uninstall:
	helm delete $(APP_NAME) --purge

.PHONE: app/upgrade
app/upgrade:
	helm upgrade $(APP_NAME) divvycloud
