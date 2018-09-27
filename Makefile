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


.PHONY: create/plugins
create/plugins:
	mkdir -p .build/plugins/
	zip .build/plugins/plugins.zip plugins/*
	kubectl create secret generic divvycloud-plugins --from-file=.build/plugins/plugins.zip
