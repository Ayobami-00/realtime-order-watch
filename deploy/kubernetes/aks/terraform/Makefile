ENVIRONMENT ?= prod
COMPANY_NAME ?= row
IS_COMPANY_DEPLOYED ?= false
DEPLOYMENT_STAGE ?= 1
AKS_CLUSTER_NAME ?= "row-prod-aks-cluster"

STORAGE_ACCOUNT_NAME = $(COMPANY_NAME)$(ENVIRONMENT)storage

STORAGE_CONTAINER_NAME = tfstatefiles
SUBSCRIPTION_ID = "cc6d3fa6-0fb8-4a02-a1b8-aca152787032"

AKS_RESOURCE_GROUP_NAME = $(COMPANY_NAME)-$(ENVIRONMENT)-aks-resource-group

AKS_LOCATION = eastus2

bootstrap-backend:
	cd bootstrap/backend && \
	terraform init && \
	terraform apply -var="subscription_id=$(SUBSCRIPTION_ID)" \
		-var="storage_account_name=$(STORAGE_ACCOUNT_NAME)" \
		-var="container_name=$(STORAGE_CONTAINER_NAME)" \
		-var="aks_resource_group_name=$(AKS_RESOURCE_GROUP_NAME)" \
		-var="aks_location=$(AKS_LOCATION)" \
		-auto-approve && \
	rm -rf .terraform* && \
	rm -rf terraform.tfstate*


create-or-update-deployment:
	cd deployments/$(ENVIRONMENT) && \
	echo 'storage_account_name = "$(STORAGE_ACCOUNT_NAME)"\nresource_group_name = "$(AKS_RESOURCE_GROUP_NAME)"\ncontainer_name = "$(STORAGE_CONTAINER_NAME)"' > backend.hcl && \
	terraform init -upgrade -backend-config=./backend.hcl && \
	terraform apply -var="subscription_id=$(SUBSCRIPTION_ID)" \
		-var="storage_account_name=$(STORAGE_ACCOUNT_NAME)" \
		-var="aks_resource_group_name=$(AKS_RESOURCE_GROUP_NAME)" \
		-var="aks_location=$(AKS_LOCATION)" \
		-var="company_name=$(COMPANY_NAME)" \
		-var="is_company_deployed=$(IS_COMPANY_DEPLOYED)" \
		-var="storage_container_name=$(STORAGE_CONTAINER_NAME)" \
		-var="deployment_stage=$(DEPLOYMENT_STAGE)" \
		-var="aks_cluster_name=$(AKS_CLUSTER_NAME)" \
		-lock=false -auto-approve 
 
destroy-deployment:
	cd deployments/$(ENVIRONMENT) && \
	terraform destroy -var="subscription_id=$(SUBSCRIPTION_ID)" \
		-var="storage_account_name=$(STORAGE_ACCOUNT_NAME)" \
		-var="aks_resource_group_name=$(AKS_RESOURCE_GROUP_NAME)" \
		-var="aks_location=$(AKS_LOCATION)" \
		-var="company_name=$(COMPANY_NAME)" \
		-var="is_company_deployed=$(IS_COMPANY_DEPLOYED)" \
		-var="storage_container_name=$(STORAGE_CONTAINER_NAME)" \
		-var="deployment_stage=$(DEPLOYMENT_STAGE)" \
		-var="aks_cluster_name=$(AKS_CLUSTER_NAME)" \
		-auto-approve


.PHONY: bootstrap-backend create-or-update-deployment 

