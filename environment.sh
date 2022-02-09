#!/usr/bin/env bash

export BASE_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
source ${BASE_DIR}/helpers.sh

check_local_requirements

### GCP SECTION ###
export GCP_PROJECT_ID=bart-istio-demo
export GCP_KOPS_BUCKET=bart-gcp-tid-multi
export GCP_DOMAIN=k8s.local
export GCP_SSH_CIDR=$(curl ipinfo.io/ip)/32

### KOPS SECTION ###
export KOPS_FEATURE_FLAGS=AlphaAllowGCE
export KOPS_STATE_STORE=gs://${GCP_KOPS_BUCKET}

### K8S SECTION ###
export K8S_VERSION=1.20.7

export K8S_CL1_NAME=tid-cluster1.${GCP_DOMAIN}
export K8S_CL1_ZONES=europe-north1-a,europe-north1-b,europe-north1-c
export K8S_CL1_LABELS=Owner=BartVanBos,Team=PreSales,Purpose=MultiCluster,Email=bart@tetrate.io,Cluster=${K8S_CL1_NAME}

export K8S_CL2_NAME=tid-cluster2.${GCP_DOMAIN}
export K8S_CL2_ZONES=europe-west1-b,europe-west1-c,europe-west1-d
export K8S_CL2_LABELS=Owner=BartVanBos,Team=PreSales,Purpose=MultiCluster,Email=bart@tetrate.io,Cluster=${K8S_CL2_NAME}

### ISTIO SECTION ###
export ISTIO_VERSION=1.11.3
export ISTIO_FLAVOR=istio
# export ISTIO_FLAVOR=tetrate
# export ISTIO_FLAVOR=tetratefips

### OUTPUT SECTION ###
export KOPS_CONFIG_CL1=${BASE_DIR}/output/kops-${K8S_CL1_NAME}.yaml
export K8S_KUBECONF_CL1=${BASE_DIR}/output/kubeconfig-${K8S_CL1_NAME}.yaml
export CROSS_SECRET_CL1=${BASE_DIR}/output/cross-secret-${K8S_CL1_NAME}.yaml

export KOPS_CONFIG_CL2=${BASE_DIR}/output/kops-${K8S_CL2_NAME}.yaml
export K8S_KUBECONF_CL2=${BASE_DIR}/output/kubeconfig-${K8S_CL2_NAME}.yaml
export CROSS_SECRET_CL2=${BASE_DIR}/output/cross-secret-${K8S_CL2_NAME}.yaml
