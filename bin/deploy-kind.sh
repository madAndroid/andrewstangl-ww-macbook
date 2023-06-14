#!/usr/bin/env bash

# Utility to deploy kind cluster
# Version: 1.0
# Author: Paul Carlton (mailto:paul.carlton@weave.works)

set -euo pipefail

function usage()
{
    echo "usage ${0} [--debug] [--install] [--username <username>] [--cluster-name <hostname>]  [--hostname <hostname>] [--listen-address <ip address>] [--listen-port <port>]" >&2
    echo "This script will deploy Kubernetes cluster on the local machine or another host" >&2
    echo "The target machine must be accessible via ssh using hostname, add the hostname to /etc/hosts if needed first" >&2

}

function args() {
  install=""
  username_str=""
  listen_address="127.0.0.1"
  listen_port="6443"
  hostname=""
  cluster_name="kind"

  arg_list=( "$@" )
  arg_count=${#arg_list[@]}
  arg_index=0
  while (( arg_index < arg_count )); do
    case "${arg_list[${arg_index}]}" in
          "--install") install=true;;
          "--cluster-name") (( arg_index+=1 )); cluster_name="${arg_list[${arg_index}]}";;
          "--hostname") (( arg_index+=1 )); hostname="${arg_list[${arg_index}]}";;
          "--username") (( arg_index+=1 )); username_str="${arg_list[${arg_index}]}@";;
          "--listen-address") (( arg_index+=1 )); listen_address="${arg_list[${arg_index}]}";;
          "--listen-port") (( arg_index+=1 )); listen_port="${arg_list[${arg_index}]}";;
          "--debug") set -x; debug_str="--debug";;
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

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
pushd $SCRIPT_DIR/.. >/dev/null
source .envrc

if [ -z "${hostname}" ]; then
  scp -r kind-leafs ${username_str}${hostname}:/tmp

  cat .envrc | grep "export GITHUB_MGMT_" > /tmp/env.sh
  echo "export GITHUB_TOKEN=${GITHUB_TOKEN}" >> /tmp/env.sh
  echo "export listen_address=${listen_address}" >> /tmp/env.sh
  echo "export listen_port=${listen_port}" >> /tmp/env.sh
  echo "export cluster_name=${cluster_name}" >> /tmp/env.sh
  echo "export KUBECONFIG=/tmp/kubeconfig" >> /tmp/env.sh
  scp -r /tmp/env.sh ${username_str}${hostname}:/tmp

  scp -r resources/kind.yaml ${username_str}${hostname}:/tmp

  if [ -n "$install" ]; then
    ssh ${username_str}${hostname} "source /tmp/kind-leafs/leaf-install.sh $debug_str"
  fi

  ssh ${username_str}${hostname} "source /tmp/kind-leafs/leaf-deploy.sh $debug_str"

  scp ${username_str}${hostname}:/tmp/kubeconfig ~/.kube/${hostname}-${cluster_name}.kubeconfig

  echo "Cluster ${cluster_name} deployed on ${hostname}, use the following KUBECONFIG to access it:"
  echo "export KUBECONFIG=~/.kube/${hostname}-${cluster_name}.kubeconfig" 
else
  if [ -n "$install" ]; then
    kind-leafs/leaf-install.sh $debug_str
  fi

  cp resources/kind.yaml /tmp

  export hostname=localhost
  
  kind-leafs/leaf-deploy.sh $debug_str

  cp /tmp/kubeconfig ~/.kube/localhost-${cluster-name}.kubeconfig

  echo "Cluster ${cluster_name} deployed on localhost, use the following KUBECONFIG to access it:"
  echo "export KUBECONFIG=~/.kube/localhost-${cluster_name}.kubeconfig" 
fi

