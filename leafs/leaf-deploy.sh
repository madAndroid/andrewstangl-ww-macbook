#!/usr/bin/env bash

# Utility to deploy kubernetes on Ubuntu
# Version: 1.0
# Author: Paul Carlton (mailto:paul.carlton@weave.works)

set -euo pipefail

function usage()
{
    echo "usage ${0} [--debug] " >&2
    echo "This script will deploy Kubernetes on Ubuntu" >&2
}

function args() {
  arg_list=( "$@" )
  arg_count=${#arg_list[@]}
  arg_index=0
  while (( arg_index < arg_count )); do
    case "${arg_list[${arg_index}]}" in
          "--debug") set -x;;
               "-h") usage; exit;;
           "--help") usage; exit;;
               "-?") usage; exit;;
        *) if [ "${arg_list[${arg_index}]:0:2}" == "--" ];then
               echo "invalid argument: ${arg_list[${arg_index}]}" >&2
               usage; exit
           fi;
           break;;
    esac
    (( arg_index+=1 ))
  done
}

args "$@"

hostname=$(hostname)
sudo kubeadm init --ignore-preflight-errors=NumCPU --pod-network-cidr 192.168.0.0/16 --kubernetes-version v1.27.0 --apiserver-cert-extra-sans $hostname

mkdir -p $HOME/.kube
sudo cp -rf /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
kubectl get nodes

kubectl get pods -A
sudo systemctl --no-pager status kubelet -l


cat $KUBECONFIG | sed s%https://.*:6443%https://$hostname:6443%g > /tmp/kubeconfig

flux bootstrap gitlab --owner $GITHUB_MGMT_ORG --repository $GITHUB_MGMT_REPO --token-auth \
  --path=${target_path}/flux
flux --version
flux bootstrap github --owner $GITHUB_MGMT_ORG --repository $GITHUB_MGMT_REPO --path cluster/clusters/leafs/$hostname/flux
