# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

########################
#### KOPS Clusters  ####
########################

glcoud-init: ## Login into GCP environment and prepare it for kops
	./scripts/gcloud.sh login
	./scripts/gcloud.sh create-kops-bucket

kops-prepare-clusters: ## Prepare kops cluster configurationss
	./scripts/kops.sh prepare-clusters

kops-create-clusters: ## Create kops clusters from yaml configs
	./scripts/kops.sh create-clusters
	./scripts/kops.sh kubeconfig-clusters

kops-update-clusters: ## Update kops clusters from yaml configs
	./scripts/kops.sh update-clusters

kops-delete-clusters: ## Delete kops clusters
	./scripts/kops.sh delete-clusters

kops-refresh-credentials: ## Refreshing kubernetes admin credentials
	./scripts/kops.sh refesh-credentials

kops-info-clusters: ## Get info of kops clusters
	./scripts/kops.sh info-clusters


###############
#### Istio ####
###############

istio-certs: ## Install istio certificates
	./scripts/istio.sh install-certs

istio-install: istio-certs ## Install Tetrate Istio Distro
	./scripts/istio.sh install-istio

istio-info: ## Get Tetrate Istio Distro information
	./scripts/istio.sh info-istio


###################
#### Workloads ####
###################

deploy-json-client: ## Install json-client workloads
	./workloads/workloads.sh deploy-json-client

deploy-json-server: ## Install json-server workloads
	./workloads/workloads.sh deploy-json-server

undeploy-json-client: ## Uninstall json-client workloads
	./workloads/workloads.sh undeploy-json-client

undeploy-json-server: ## Uninstall json-server workloads
	./workloads/workloads.sh undeploy-json-server

undeploy-all: ## Uninstall json-client, json-server and namespaces
	./workloads/workloads.sh undeploy-all

workload-commands: ## Print the workload commands
	./workloads/workloads.sh workload-commands


#################
#### Helpers ####
#################

clean:
	rm -f output/*.yaml
