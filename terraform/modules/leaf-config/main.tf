resource "kubectl_manifest" "cluster_sa" {
  yaml_body = <<-YAML
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: ${var.cluster_name}
      namespace: default
  YAML
}

resource "kubectl_manifest" "cluster_sa_token" {
  yaml_body = <<-YAML
    apiVersion: v1
    kind: Secret
    metadata:
      name: ${kubectl_manifest.cluster_sa.name}-token
      namespace: default
      annotations:
        kubernetes.io/service-account.name: ${kubectl_manifest.cluster_sa.name}
    type: kubernetes.io/service-account-token
  YAML

  depends_on = [kubectl_manifest.cluster_sa]
}

resource "kubectl_manifest" "impersonator_cluster_role" {
  yaml_body = <<-YAML
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: user-groups-impersonator
    rules:
      - apiGroups: [""]
        resources: ["users", "groups"]
        verbs: ["impersonate"]
      - apiGroups: [""]
        resources: ["namespaces"]
        verbs: ["get", "list"]
      - apiGroups: ["apiextensions.k8s.io"]
        resources: ["customresourcedefinitions"]
        verbs: ["get", "list"]
  YAML
}

resource "kubectl_manifest" "impersonator_cluster_role_binding" {
  yaml_body = <<-YAML
    apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: impersonate-user-groups
    subjects:
      - kind: ServiceAccount
        name: ${kubectl_manifest.cluster_sa.name}
        namespace: default
    roleRef:
      kind: ClusterRole
      name: ${kubectl_manifest.impersonator_cluster_role.name}
      apiGroup: rbac.authorization.k8s.io
  YAML

  depends_on = [kubectl_manifest.impersonator_cluster_role]
}

data "kubernetes_secret" "cluster_sa_token" {
  metadata {
    name      = kubectl_manifest.cluster_sa_token.name
    namespace = kubectl_manifest.cluster_sa_token.namespace
  }

  depends_on = [kubectl_manifest.cluster_sa_token]
}

locals {
  config_name       = "${var.cluster_name}-kubeconfig"
  vault_secret_name = "leaf-clusters/${local.config_name}"
  kubeconfig = templatefile("${path.module}/templates/kubeconfig.tftpl", {
    cluster = {
      name                       = var.cluster_name,
      certificate_authority_data = var.cluster_ca_certificate,
      server                     = var.cluster_endpoint
    },
    user = {
      name  = kubectl_manifest.cluster_sa.name
      token = data.kubernetes_secret.cluster_sa_token.data.token
    }
  })

  kubeconfig_secret = templatefile("${path.module}/templates/kubeconfig_secret.tftpl", {
    resource_name = local.config_name
    secret_name   = local.vault_secret_name
  })
}

resource "vault_kv_secret_v2" "kubeconfig" {
  mount               = var.vault_secrets_path
  name                = local.vault_secret_name
  delete_all_versions = true
  data_json           = jsonencode({ "value.yaml" = local.kubeconfig })
}

resource "gitlab_repository_file" "kubeconfig" {
  project        = var.repository_id
  branch         = var.branch
  file_path      = "clusters/management/secrets/leaf-clusters/${local.config_name}.yaml"
  content        = base64encode(local.kubeconfig_secret)
  author_email   = var.commit_email
  author_name    = var.commit_author
  commit_message = "Add clusters/management/secrets/leaf-clusters/${local.config_name}.yaml"
}
