#!/usr/bin/env bash

# Utility refreshing local kubernetes cluster
# Version: 1.0
# Author: Paul Carlton (mailto:paul.carlton@weave.works)

. ww-aws.sh
aws-secrets.sh

export AWS_B64ENCODED_CREDENTIALS=$(clusterawsadm bootstrap credentials encode-as-profile)
clusterctl init --infrastructure aws

kubectl rollout restart deployment -n flux-system  source-controller 
kubectl rollout restart deployment -n flux-system  kustomize-controller 
kubectl rollout restart deployment -n flux-system  weave-gitops-enterprise-mccp-cluster-service