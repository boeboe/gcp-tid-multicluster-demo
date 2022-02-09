#!/usr/bin/env bash

# set -o xtrace

export BASE_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && cd .. && pwd )
source ${BASE_DIR}/environment.sh

shopt -s expand_aliases
alias k1="kubectl --context=${K8S_CL1_NAME}"
alias k2="kubectl --context=${K8S_CL2_NAME}"
alias istioctl1="getmesh istioctl --context ${K8S_CL1_NAME}"
alias istioctl2="getmesh istioctl --context ${K8S_CL2_NAME}"

generate_json_server_yaml() {
  mkdir -p ${BASE_DIR}/workloads/generated/${K8S_CL1_NAME}
  mkdir -p ${BASE_DIR}/workloads/generated/${K8S_CL2_NAME}

  CL1_REGION=$(k1 get nodes -o json | jq -r '.items[].metadata.labels."topology.kubernetes.io/region"' | sort | uniq)
  CL1_ZONES=$(k1 get nodes -o json | jq -r '.items[].metadata.labels."topology.kubernetes.io/zone"' | sort | uniq)

  i=0
  for zone in ${CL1_ZONES}; do
    cat ${BASE_DIR}/workloads/json-server.tpl.yaml \
      | sed "s/REPLACE_INDEX/${i}/g" \
      | sed "s/REPLACE_REGION/${CL1_REGION}/g" \
      | sed "s/REPLACE_ZONE/${zone}/g" \
      > ${BASE_DIR}/workloads/generated/${K8S_CL1_NAME}/json-server-${i}.yaml
    let "i=i+1"
  done

  CL2_REGION=$(k2 get nodes -o json | jq -r '.items[].metadata.labels."topology.kubernetes.io/region"' | sort | uniq)
  CL2_ZONES=$(k2 get nodes -o json | jq -r '.items[].metadata.labels."topology.kubernetes.io/zone"' | sort | uniq)

  j=0
  for zone in ${CL2_ZONES}; do
    cat ${BASE_DIR}/workloads/json-server.tpl.yaml \
      | sed "s/REPLACE_INDEX/${j}/g" \
      | sed "s/REPLACE_REGION/${CL2_REGION}/g" \
      | sed "s/REPLACE_ZONE/${zone}/g" \
      > ${BASE_DIR}/workloads/generated/${K8S_CL2_NAME}/json-server-${j}.yaml
    let "j=j+1"
  done
}


if [[ $1 = "deploy-json-client" ]]; then
  k1 apply -f ${BASE_DIR}/workloads/namespaces.yaml
  k1 apply -f ${BASE_DIR}/workloads/json-client.yaml

  k2 apply -f ${BASE_DIR}/workloads/namespaces.yaml
  k2 apply -f ${BASE_DIR}/workloads/json-client.yaml

  print_info "Workload json-client deployed"
  exit 0
fi


if [[ $1 = "deploy-json-server" ]]; then
  generate_json_server_yaml

  k1 apply -f ${BASE_DIR}/workloads/namespaces.yaml
  k1 apply -f ${BASE_DIR}/workloads/json-server.yaml
  k1 apply -f ${BASE_DIR}/workloads/generated/${K8S_CL1_NAME}

  k2 apply -f ${BASE_DIR}/workloads/namespaces.yaml
  k2 apply -f ${BASE_DIR}/workloads/json-server.yaml
  k2 apply -f ${BASE_DIR}/workloads/generated/${K8S_CL2_NAME}

  print_info "Workload json-server deployed"
  exit 0
fi


if [[ $1 = "undeploy-json-client" ]]; then
  k1 delete -f ${BASE_DIR}/workloads/json-client.yaml
  k2 delete -f ${BASE_DIR}/workloads/json-client.yaml
  print_info "Workload json-client removed"
  exit 0
fi


if [[ $1 = "undeploy-json-server" ]]; then
  k1 delete -f ${BASE_DIR}/workloads/json-server.yaml
  k1 delete -f ${BASE_DIR}/workloads/generated/${K8S_CL1_NAME}

  k2 delete -f ${BASE_DIR}/workloads/json-server.yaml
  k2 delete -f ${BASE_DIR}/workloads/generated/${K8S_CL2_NAME}

  print_info "Workload json-server removed"
  exit 0
fi


if [[ $1 = "undeploy-all" ]]; then
  k1 delete -f ${BASE_DIR}/workloads/json-client.yaml
  k1 delete -f ${BASE_DIR}/workloads/json-server.yaml
  k1 delete -f ${BASE_DIR}/workloads/generated/${K8S_CL1_NAME}
  k1 delete -f ${BASE_DIR}/workloads/namespaces.yaml

  k2 delete -f ${BASE_DIR}/workloads/json-client.yaml
  k2 delete -f ${BASE_DIR}/workloads/json-server.yaml
  k2 delete -f ${BASE_DIR}/workloads/generated/${K8S_CL2_NAME}
  k2 delete -f ${BASE_DIR}/workloads/namespaces.yaml
  exit 0
fi


if [[ $1 = "workload-commands" ]]; then
  print_info "Get the envoy endpoints for json-client"
  CL1_JSON_CLIENT_PODNAME=$(kubectl --context=${K8S_CL1_NAME} get pod -n srcns -l app=json-client -o jsonpath='{.items[0].metadata.name}')
  CL2_JSON_CLIENT_PODNAME=$(kubectl --context=${K8S_CL2_NAME} get pod -n srcns -l app=json-client -o jsonpath='{.items[0].metadata.name}')

  print_command "getmesh istioctl --context ${K8S_CL1_NAME} proxy-config endpoint ${CL1_JSON_CLIENT_PODNAME}.srcns"
  print_command "getmesh istioctl --context ${K8S_CL2_NAME} proxy-config endpoint ${CL2_JSON_CLIENT_PODNAME}.srcns"

  print_info "Get the cluster priorities for json-client"
  print_command "kubectl exec --context=${K8S_CL1_NAME} -n srcns ${CL1_JSON_CLIENT_PODNAME} -c json-client -- curl -s localhost:15000/clusters | grep -E '.*::priority|priority.*'"
  print_command "kubectl exec --context=${K8S_CL2_NAME} -n srcns ${CL2_JSON_CLIENT_PODNAME} -c json-client -- curl -s localhost:15000/clusters | grep -E '.*::priority|priority.*'"
  exit 0
fi


print_error "Please specify correct option"
exit 1