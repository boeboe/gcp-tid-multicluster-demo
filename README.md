# TIB (Tetrate Istio Distribution) demo on GCP with KOPS

## Setup

Change `environment.sh` to meet your requirements and environment

## Run

To start the demo, use make to go through the process


```
  # make

  help                           This help
  glcoud-init                    Login into GCP environment and prepare it for kops
  kops-create-clusters           Create kops clusters from yaml configs
  kops-update-clusters           Update kops clusters from yaml configs
  kops-delete-clusters           Delete kops clusters
  kops-refresh-credentials       Refreshing kubernetes admin credentials
  kops-info-clusters             Get info of kops clusters
  istio-certs                    Install istio certificates
  istio-install                  Install Tetrate Istio Distro
  istio-info                     Get Tetrate Istio Distro information
  deploy-json-client             Install json-client workloads
  deploy-json-server             Install json-server workloads
  undeploy-json-client           Uninstall json-client workloads
  undeploy-json-server           Uninstall json-server workloads
  undeploy-all                   Uninstall json-client, json-server and namespaces
  workload-commands              Print the workload commands
  clean                          Clean temporary artifacts
  reset                          Pave and nuke
```  