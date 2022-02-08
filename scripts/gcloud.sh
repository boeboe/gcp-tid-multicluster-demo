#!/usr/bin/env bash

# set -o xtrace

export BASE_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && cd .. && pwd )
source ${BASE_DIR}/environment.sh

if [[ $1 = "login" ]]; then
  if [[ $(gcloud config get-value project) != ${GCP_PROJECT_ID} ]]; then
    gcloud auth login
  fi

  if ! gcloud auth application-default print-access-token; then
    gcloud auth application-default login
  fi

  gcloud config set project ${GCP_PROJECT_ID}
  gcloud config get-value project
  print_info "Successfully switched to GCP project ${GCP_PROJECT_ID}"
  exit 0
fi

if [[ $1 = "create-kops-bucket" ]]; then
  if ! gsutil ls gs://${GCP_KOPS_BUCKET}; then
    gsutil mb gs://${GCP_KOPS_BUCKET}
  fi
  
  print_info "Kops state bucket gs://${GCP_KOPS_BUCKET} available"
  exit 0
fi


print_error "Please specify correct option"
exit 1