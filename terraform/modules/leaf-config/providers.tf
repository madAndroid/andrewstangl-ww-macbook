terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.33"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "~> 15.7"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.14"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4.3"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.2.2"
    }
  }
}
