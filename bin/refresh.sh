#!/usr/bin/env bash

# Utility refreshing local kubernetes cluster
# Version: 1.0
# Author: Paul Carlton (mailto:paul.carlton@weave.works)

. ww-aws.sh
aws-secrets.sh

export AWS_B64ENCODED_CREDENTIALS=$(clusterawsadm bootstrap credentials encode-as-profile)
export EXP_EKS=true
export EXP_MACHINE_POOL=true
export CAPA_EKS_IAM=false
export EXP_CLUSTER_RESOURCE_SET=true

clusterctl init --infrastructure aws

kubectl rollout restart deployment -n flux-system  source-controller 
kubectl rollout restart deployment -n flux-system  kustomize-controller 
kubectl rollout restart deployment -n flux-system  weave-gitops-enterprise-mccp-cluster-service