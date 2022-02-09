#!/usr/bin/env bash

# set -o xtrace

export BASE_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && cd .. && pwd )
source ${BASE_DIR}/environment.sh


if [[ $1 = "prepare-clusters" ]]; then
  kops create cluster \
    --cloud-labels "${K8S_CL1_LABELS}" \
    --kubernetes-version ${K8S_VERSION} \
    --master-count 1 \
    --name ${K8S_CL1_NAME} \
    --node-count 3 \
    --project=${GCP_PROJECT_ID} \
    --ssh-access ${GCP_SSH_CIDR} \
    --zones "${K8S_CL1_ZONES}"

  kops create cluster \
    --cloud-labels "${K8S_CL2_LABELS}" \
    --kubernetes-version ${K8S_VERSION} \
    --master-count 1 \
    --name ${K8S_CL2_NAME} \
    --node-count 3 \
    --project=${GCP_PROJECT_ID} \
    --ssh-access ${GCP_SSH_CIDR} \
    --zones "${K8S_CL2_ZONES}"

  kops get cluster --name ${K8S_CL1_NAME} --output yaml > ${KOPS_CONFIG_CL1}
  kops get cluster --name ${K8S_CL2_NAME} --output yaml > ${KOPS_CONFIG_CL2}

  print_info "Create kops cluster configuration in ${BASE_DIR}/output"
  exit 0
fi


if [[ $1 = "create-clusters" || $1 = "update-clusters" ]]; then
  kops update cluster --name ${K8S_CL1_NAME} --yes --admin
  kops update cluster --name ${K8S_CL2_NAME} --yes --admin

  kops validate cluster --name ${K8S_CL1_NAME} --wait 10m
  kops validate cluster --name ${K8S_CL2_NAME} --wait 10m

  print_info "Kops clusters created/updated"
  exit 0
fi


if [[ $1 = "kubeconfig-clusters" ]]; then
  kops export kubeconfig ${K8S_CL1_NAME} --admin --kubeconfig ${K8S_KUBECONF_CL1}
  kops export kubeconfig ${K8S_CL2_NAME} --admin --kubeconfig ${K8S_KUBECONF_CL2}

  print_info "Kubeconfig files exported"
  exit 0
fi


if [[ $1 = "refesh-credentials" ]]; then
  kops export kubeconfig ${K8S_CL1_NAME} --admin
  kops export kubeconfig ${K8S_CL2_NAME} --admin
  kops export kubeconfig ${K8S_CL1_NAME} --admin --kubeconfig ${K8S_KUBECONF_CL1}
  kops export kubeconfig ${K8S_CL2_NAME} --admin --kubeconfig ${K8S_KUBECONF_CL2}

  print_info "Credentials refreshed"
  exit 0
fi


if [[ $1 = "info-clusters" ]]; then
  print_info "Kops cluster states"
  kops get clusters --state ${KOPS_STATE_STORE}

  print_info "Kops instance groups"
  kops get instancegroup --name ${K8S_CL1_NAME}
  kops get instancegroup --name ${K8S_CL2_NAME}

  print_info "Kubectl node info"
  print_command "kubectl --context=${K8S_CL1_NAME} get nodes -o wide"
  kubectl --context=${K8S_CL1_NAME} get nodes -o wide
  print_command "kubectl --context=${K8S_CL2_NAME} get nodes -o wide"
  kubectl --context=${K8S_CL2_NAME} get nodes -o wide
  exit 0
fi


if [[ $1 = "delete-clusters" ]]; then
  kops delete cluster --name ${K8S_CL1_NAME} --yes
  kops delete cluster --name ${K8S_CL2_NAME} --yes

  print_info "Kops clusters deleted"
  exit 0
fi


print_error "Please specify correct option"
exit 1