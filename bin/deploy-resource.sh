
#!/usr/bin/env bash

# Utility creating resources
# Version: 1.0
# Author: Paul Carlton (mailto:paul.carlton@weave.works)

set -euo pipefail

function usage()
{
    echo "usage ${0} [--debug] [--template-name <template-name>] [--namespace <namespace>] [--resource-name <resource-name>]" >&2
    echo "This script will create resources" >&2
    echo " The --template-name option is used to specify the template name" >&2
    echo " The --namespace option is used to specify the namespace" >&2
    echo " The --resource-name option is used to specify the resource name" >&2
}

function args() {
  template_name=""
  resource_name=""
  namespace=""

  arg_list=( "$@" )
  arg_count=${#arg_list[@]}
  arg_index=0
  while (( arg_index < arg_count )); do
    case "${arg_list[${arg_index}]}" in
          "--template-name") (( arg_index+=1 ));template_name=${arg_list[${arg_index}]};;
          "--namespace") (( arg_index+=1 ));namespace=${arg_list[${arg_index}]};;
          "--resource-name") (( arg_index+=1 ));resource_name=${arg_list[${arg_index}]};;
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

  if [ -z "$template_name" ]; then
    echo "missing --template-name option" >&2
    usage; exit
  fi

  if [ -z "$namespace" ]; then
    echo "missing --namespace option" >&2
    usage; exit
  fi

  if [ -z "$resource_name" ]; then
    echo "missing --resource_name option" >&2
    usage; exit
  fi
}

args "$@"

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
pushd $SCRIPT_DIR/.. >/dev/null
source .envrc

export nameSpace=$namespace
cat cluster/namespace/$template_name.yaml| envsubst > /tmp/$template_name.yaml
gitops create template /tmp/$template_name.yaml --values RESOURCE_NAME=$resource_name AWS_REGION=$AWS_REGION --output-dir .;git add -A ; git commit -a -m "create resource $resource_name";git pull;git push
