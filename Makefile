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
