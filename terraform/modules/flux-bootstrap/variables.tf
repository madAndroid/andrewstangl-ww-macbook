variable "aws_region" {
  type        = string
  description = "aws region"
  default     = "us-east-1"
}

variable "cluster_name" {
  type        = string
  description = "kubernetes cluster name"
}

variable "gitlab_owner" {
  type        = string
  description = "gitlab group name"
}

variable "repository_name" {
  type        = string
  description = "gitlab repository name"
}

variable "branch" {
  type        = string
  description = "branch name"
  default     = "main"
}

variable "target_path" {
  type        = string
  description = "flux sync target path"
  default     = ""
}

variable "allow_push_access" {
  type        = bool
  description = "configure the deploy key with read/write permissions"
  default     = false
}

variable "flux_version" {
  type        = string
  description = "version of flux to bootstrap"
  default     = null
}

variable "flux_namespace" {
  type        = string
  description = "namespace to bootstrap flux"
  default     = "flux-system"
}

variable "use_existing_repository" {
  type        = bool
  description = "bootstrap flux into an existing repository instead of creating a new repository"
}

variable "repository_visibility" {
  type        = string
  description = "repository visibility when creating a new repository (only valid when `use_existing_repository` is set to false)"
  default     = "private"
}

variable "kustomization_patches" {
  type        = string
  description = "kustomization patches to append to the flux kustomiztion file"
  default     = ""
}

variable "commit_author" {
  type        = string
  description = "git commit email"
  default     = null
}

variable "commit_email" {
  type        = string
  description = "git commit email"
  default     = null
}

variable "archive_on_destroy" {
  type        = bool
  description = "archive the repository instead of deleting it on destroy"
  default     = false
}

variable "gitlab_hostname" {
  type        = string
  description = "hostname for gitlab instance (do not include http(s)://)"
  default     = "gitlab.com"
}

variable "gitlab_known_hosts" {
  type        = string
  description = "known host key for gitlab host. run `ssh-keyscan <gitlab_hostname>` to find keys. use the 'ecdsa-sha2-nistp256' key"
  default     = "gitlab.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFSMqzJeV9rUzU4kWitGjeR4PWSa29SPqJ1fVkhtj3Hw9xjLVXVYrU9QlYWrOLXBpQ6KWjbjTDTdDkoohFzgbEY="
}
