variable "region" {
  type        = string
  description = "AWS region for cluster"
  default     = "us-east-1"
}

variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "tags" {
  type        = map(string)
  description = "resource specific tags"
  default     = {
    customer   = "weaveworks-cx"
    projectGid = "20276"
    creator    = "paul-carlton@weave.works"
  }
}

variable "gitlab_url" {
  type        = string
  description = "gitlab url"
  default     = "https://gitlab.com"
}

variable "gitlab_known_hosts" {
  type        = string
  description = "known hosts for gitlab host (use `ssh-keyscan <gitlab_host>` to find key. use the 'ecdsa-sha2-nistp256' key)"
  default     = "gitlab.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFSMqzJeV9rUzU4kWitGjeR4PWSa29SPqJ1fVkhtj3Hw9xjLVXVYrU9QlYWrOLXBpQ6KWjbjTDTdDkoohFzgbEY="
}

variable "gitlab_token" {
  type        = string
  description = "gitlab token"
  default     = null
  sensitive   = true
}

variable "gitlab_owner" {
  type        = string
  description = "gitlab owner"
}

variable "repository_name" {
  type        = string
  description = "github repository name"
}

variable "repository_visibility" {
  type        = string
  description = "How visible is the github repo"
  default     = "private"
}

variable "branch" {
  type        = string
  description = "branch name"
  default     = "main"
}

variable "target_path" {
  type        = string
  description = "flux sync target path"
}

variable "flux_sync_directory" {
  type        = string
  description = "directory within target_path to sync flux"
  default     = "flux"
}

variable "route53_main_domain" {
  type        = string
  description = "main domain address (leaf domain will be built using <cluster_name>.<route53_main_domain> format)"
}

variable "desired_size" {
  type        = number
  description = "Desired number of instances in Node Group"
  default     = 2
}

variable "max_size" {
  type        = number
  description = "Max number of instances in Node Group"
  default     = 4
}

variable "min_size" {
  type        = number
  description = "Min number of instances in Node Group"
  default     = 1
}

variable "shrink" {
  type        = bool
  description = "Shrink worker node group"
  default     = false
}

variable "capacity_type" {
  type        = string
  description = "Capacity associated with Node Group (SPOT or ON_DEMAND)"
  default     = null
}

variable "instance_type" {
  type        = string
  description = "Instance type associated with Node Group"
  default     = "t3.large"
}

variable "git_commit_author" {
  type        = string
  description = "Git commit author (defaults to author value from auth)"
  default     = null
}

variable "git_commit_email" {
  type        = string
  description = "Git commit email (defaults to email value from auth)"
  default     = null
}

variable "git_commit_message" {
  type        = string
  description = "Set custom commit message"
  default     = null
}

variable "vault_url" {
  type        = string
  description = "vault url"
}

variable "vault_auth_mount" {
  type        = string
  description = "mount path for vault auth"
  default     = "kubernetes"
}

variable "vault_auth_role" {
  type        = string
  description = "auth role to use for vault login"
  default     = "tf-runner"
}

variable "cluster_secrets_path" {
  type        = string
  description = "vault path for cluster secrets"
  default     = "secrets"
}

variable "leaf_cluster_secrets_path" {
  type        = string
  description = "vault path for leaf cluster secrets"
  default     = "leaf-cluster-secrets"
}

variable "wge_profiles_auth" {
  type        = string
  description = "name of vault secret that contains the wge profiles auth credentials"
  default     = null
}

variable "dish_cnfs_path" {
  type        = string
  description = "git repository path to dish cnfs config files"
  default     = "dish-cnfs"
}

variable "include_bases" {
  type        = bool
  description = "create bases kustomization"
  default     = true
}

variable "bases_path" {
  type        = string
  description = "git repo path to bases files"
  default     = "bases"
}

variable "eks_core_state_bucket" {
  type        = string
  description = "s3 bucket that contains eks core module outputs"
}

variable "eks_core_state_key" {
  type        = string
  description = "key for s3 bucket that contains eks core module outputs"
}

variable "harbor_registry" {
  type        = string
  description = "Harbor registry"
}

variable "wge_profiles_url" {
  type        = string
  description = "repo url for WGE Profiles"
  default     = "https://weaveworks.github.io/profiles-catalog"
}

variable "cluster_admin_roles_string" {
  type        = string
  description = "comma seperated string of IAM roles to be granted admin access in eks aws_auth configmap"
  default     = "AdministratorAccess"
}

variable "cluster_admin_users_string" {
  type        = string
  description = "comma seperated string of IAM users to be granted admin access in eks aws_auth configmap"
  default     = "russell.parmer@weave.works,clifford.thurber@weave.works,paul.carlton@weave.works"
}


