resource "vault_policy" "cluster_secrets" {
  name = "${var.cluster_name}-secrets"

  policy = <<-EOF
    path "${var.cluster_secrets_path}/*" {
      capabilities = ["read"]
    }

    path "${var.leaf_cluster_secrets_path}/*" {
      capabilities = ["read"]
    }
  EOF
}

resource "kubernetes_service_account_v1" "external_secrets_vault" {
  metadata {
    name      = "vault-secrets-sa"
    namespace = "flux-system"
  }

  # required to ensure 'flux-system' namespace exists
  depends_on = [module.flux_bootstrap]
}

resource "vault_kubernetes_auth_backend_role" "external_secrets_vault" {
  backend                          = module.vault_k8s_auth.kubernetes_auth_path
  role_name                        = "external-secrets-vault"
  bound_service_account_names      = [kubernetes_service_account_v1.external_secrets_vault.metadata[0].name]
  bound_service_account_namespaces = [kubernetes_service_account_v1.external_secrets_vault.metadata[0].namespace]
  token_ttl                        = 3600
  token_policies                   = ["default", vault_policy.cluster_secrets.name]
}

module "vault_k8s_auth" {
  source             = "../../modules/vault-k8s-auth"
  kubernetes_host    = data.aws_eks_cluster.this.endpoint
  kubernetes_ca_cert = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  path               = var.cluster_name
}
