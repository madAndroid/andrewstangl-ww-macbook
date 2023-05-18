output "group" {
  description = "owner of repository flux is bootstrapped"
  value       = var.gitlab_owner
}

output "repository_name" {
  description = "name of repository flux is bootstrapped"
  value       = local.gitlab_repository.name
}

output "repository_id" {
  description = "id of repository flux is bootstrapped"
  value       = local.gitlab_repository.id
}

output "branch" {
  description = "repository branch flux is monitoring"
  value       = var.branch
}

output "target_path" {
  description = "path within repository flux is monitoring"
  value       = var.target_path
}

output "flux_namespace" {
  description = "k8s namespace flux is bootstapped"
  value       = var.flux_namespace
}
