#!/usr/bin/env bash

# Utility cleasring dynamo lock for terraform object
# Version: 1.0
# Author: Paul Carlton (mailto:paul.carlton@weave.works)


set -euo pipefail

function usage()
{
    echo "usage ${0} [--debug]" >&2
    echo "This script will delete and recreate tf custom resource impacted by..." >&2
    echo "https://github.com/fluxcd/kustomize-controller/issues/881" >&2
}

function args() {
  tf_object=""
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

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
pushd $SCRIPT_DIR/.. >/dev/null
source .envrc


flux suspend kustomization -n test-two test-eks-config-c1
kubectl delete -n test-two terraforms.infra.contrib.fluxcd.io eks-config-test-c1 &
kubectl patch terraforms.infra.contrib.fluxcd.io -n test-two eks-config-test-c1  -p '{"metadata":{"finalizers":null}}' --type=merge
flux resume kustomization -n test-two test-eks-config-c1 &
