output "repository_id" {
  description = "id of repository flux is bootstrapped"
  value       = module.flux_bootstrap.repository_id
}

output "sub_domain_name" {
  description = "name of aws route53 zone sub domain"
  value       = aws_route53_zone.sub.name
}

output "sub_domain_arn" {
  description = "arn of aws route53 zone sub domain"
  value       = aws_route53_zone.sub.arn
}

output "kubernetes_auth_path" {
  description = "kubernetes auth path"
  value       = module.vault_k8s_auth.kubernetes_auth_path
}


output "external_secrets_vault_role_name" {
  description = "external secrets vault role name"
  value       = vault_kubernetes_auth_backend_role.external_secrets_vault.role_name
}


output "external_secrets_vault_sa_name" {
  description = "kubernetes external secrets vault service account name"
  value       = kubernetes_service_account_v1.external_secrets_vault.metadata[0].name
}

output "external_secrets_vault_sa_namespace" {
  description = "kubernetes external secrets vault service account namespace"
  value       = kubernetes_service_account_v1.external_secrets_vault.metadata[0].namespace
}
