#!/usr/bin/env bash

# set -o xtrace

export BASE_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && cd .. && pwd )
source ${BASE_DIR}/environment.sh

CERT_DIR=${BASE_DIR}/certs
CERT_DIR_CL1=${CERT_DIR}/${K8S_CL1_NAME}
CERT_DIR_CL2=${CERT_DIR}/${K8S_CL2_NAME}

ISTIO_DIR=${BASE_DIR}/istio
# ISTIOCTL=/home/boeboe/Downloads/istioctl


K8S_CL1_NAME_CLEAN=$(echo ${K8S_CL1_NAME} | sed 's/\./-/g')
K8S_CL2_NAME_CLEAN=$(echo ${K8S_CL1_NAME} | sed 's/\./-/g')

shopt -s expand_aliases
alias k1="kubectl --context=${K8S_CL1_NAME}"
alias k2="kubectl --context=${K8S_CL2_NAME}"
alias istioctl1="getmesh istioctl --context ${K8S_CL1_NAME}"
alias istioctl2="getmesh istioctl --context ${K8S_CL2_NAME}"

if [[ $1 = "install-certs" ]]; then
  if ! k1 get ns istio-system; then k1 create ns istio-system; fi

  if ! k1 -n istio-system get secret cacerts; then
    k1 create secret generic cacerts -n istio-system \
    --from-file=${CERT_DIR_CL1}/ca-cert.pem \
    --from-file=${CERT_DIR_CL1}/ca-key.pem \
    --from-file=${CERT_DIR_CL1}/root-cert.pem \
    --from-file=${CERT_DIR_CL1}/cert-chain.pem
  fi

  if ! k2 get ns istio-system; then k2 create ns istio-system; fi

  if ! k2 -n istio-system get secret cacerts; then
    k2 create secret generic cacerts -n istio-system \
    --from-file=${CERT_DIR_CL2}/ca-cert.pem \
    --from-file=${CERT_DIR_CL2}/ca-key.pem \
    --from-file=${CERT_DIR_CL2}/root-cert.pem \
    --from-file=${CERT_DIR_CL2}/cert-chain.pem
  fi

  print_info "Certificates installed"
  exit 0
fi


if [[ $1 = "install-istio" ]]; then
  print_info "Switching to istio ${ISTIO_VERSION}, flavor ${ISTIO_FLAVOR}"
  getmesh switch ${ISTIO_VERSION} --flavor ${ISTIO_FLAVOR}

  print_info "Set the default network for each istio cluster"
  k1 label namespace istio-system --overwrite=true topology.istio.io/network=network1
  k2 label namespace istio-system --overwrite=true topology.istio.io/network=network2

  print_info "Install each istio cluster with east-west-gateway"
  istioctl1 install -y --set profile=default -f${ISTIO_DIR}/cluster1-operator.yaml
  istioctl2 install -y --set profile=default -f${ISTIO_DIR}/cluster2-operator.yaml

  k1 wait --timeout=5m --for=condition=Ready pods --all -n istio-system
  k2 wait --timeout=5m --for=condition=Ready pods --all -n istio-system

  print_info "Create cross-network-gateway with AUTO_PASSTHROUGH"
  k1 apply -f ${ISTIO_DIR}/cross-network-gateway.yaml
  k2 apply -f ${ISTIO_DIR}/cross-network-gateway.yaml

  print_info "Generating remote K8s API secrets for cross cluster endpoint discovery"
  istioctl1 x create-remote-secret --name=${K8S_CL1_NAME_CLEAN} > ${CROSS_SECRET_CL1}
  istioctl2 x create-remote-secret --name=${K8S_CL2_NAME_CLEAN} > ${CROSS_SECRET_CL2}

  print_info "Enable cross cluster endpoint discovery by deploying remote K8s API secrets"
  k1 apply -f ${CROSS_SECRET_CL2}
  k2 apply -f ${CROSS_SECRET_CL1}

  print_info "Istio installed"
  exit 0
fi


if [[ $1 = "info-istio" ]]; then
  print_info "Get istio info"
  k1 get po,svc -n istio-system -o wide
  k2 get po,svc -n istio-system -o wide
  exit 0
fi


print_error "Please specify correct option"
exit 1