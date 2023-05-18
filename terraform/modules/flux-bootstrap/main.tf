resource "tls_private_key" "main" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

# Flux
data "flux_install" "main" {
  target_path = var.target_path
  version     = var.flux_version
  namespace   = var.flux_namespace
}

data "flux_sync" "main" {
  target_path = var.target_path
  url         = "ssh://git@${var.gitlab_hostname}/${var.gitlab_owner}/${var.repository_name}"
  branch      = var.branch
  namespace   = var.flux_namespace
}

# Kubectl
resource "kubectl_manifest" "flux_namespace" {
  yaml_body = <<-YAML
    apiVersion: v1
    kind: Namespace
    metadata:
      name: ${data.flux_install.main.namespace}
  YAML
}

data "kubectl_file_documents" "install" {
  content = data.flux_install.main.content
}

data "kubectl_file_documents" "sync" {
  content = data.flux_sync.main.content
}

locals {
  install = [for v in data.kubectl_file_documents.install.documents : {
    data : yamldecode(v)
    content : v
    }
  ]
  sync = [for v in data.kubectl_file_documents.sync.documents : {
    data : yamldecode(v)
    content : v
    }
  ]
}

resource "kubectl_manifest" "install" {
  for_each  = { for v in local.install : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  yaml_body = each.value

  depends_on = [kubectl_manifest.flux_namespace]
}

resource "kubectl_manifest" "sync" {
  for_each  = { for v in local.sync : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  yaml_body = each.value

  depends_on = [
    kubectl_manifest.flux_namespace,
    kubectl_manifest.install
  ]
}

resource "kubectl_manifest" "flux_sync_secret" {
  yaml_body = <<-YAML
    apiVersion: v1
    kind: Secret
    metadata:
      name: ${data.flux_sync.main.secret}
      namespace: ${data.flux_sync.main.namespace}
    type: Opaque
    data:
      identity: ${base64encode(tls_private_key.main.private_key_pem)}
      identity.pub: ${base64encode(tls_private_key.main.public_key_pem)}
      known_hosts: ${base64encode(var.gitlab_known_hosts)}
  YAML

  depends_on = [kubectl_manifest.install]
}

# GitLab
data "gitlab_group" "owner" {
  full_path = var.gitlab_owner
}

data "gitlab_project" "main" {
  count = var.use_existing_repository == true ? 1 : 0

  path_with_namespace = "${data.gitlab_group.owner.path}/${var.repository_name}"
}

resource "gitlab_project" "main" {
  count = var.use_existing_repository == false ? 1 : 0

  name                   = var.repository_name
  namespace_id           = data.gitlab_group.owner.group_id
  default_branch         = var.branch
  visibility_level       = var.repository_visibility
  initialize_with_readme = true
  archive_on_destroy     = var.archive_on_destroy
}

locals {
  gitlab_repository = var.use_existing_repository == true ? data.gitlab_project.main[0] : gitlab_project.main[0]
  patched_kustomize_content = format("%s\n", trimspace(
    <<-EOF
    ${trimspace(data.flux_sync.main.kustomize_content)}
    ${trimspace(var.kustomization_patches)}
    EOF
  ))
}

resource "gitlab_deploy_key" "main" {
  project  = local.gitlab_repository.id
  title    = var.cluster_name
  key      = tls_private_key.main.public_key_openssh
  can_push = var.allow_push_access
}

resource "gitlab_repository_file" "install" {
  project        = local.gitlab_repository.id
  branch         = var.branch
  file_path      = data.flux_install.main.path
  content        = base64encode(data.flux_install.main.content)
  author_email   = var.commit_email
  author_name    = var.commit_author
  commit_message = "Add ${data.flux_install.main.path}"
}

resource "gitlab_repository_file" "sync" {
  project        = local.gitlab_repository.id
  branch         = var.branch
  file_path      = data.flux_sync.main.path
  content        = base64encode(data.flux_sync.main.content)
  author_email   = var.commit_email
  author_name    = var.commit_author
  commit_message = "Add ${data.flux_sync.main.path}"
}

resource "gitlab_repository_file" "kustomize" {
  project        = local.gitlab_repository.id
  branch         = var.branch
  file_path      = data.flux_sync.main.kustomize_path
  content        = base64encode(local.patched_kustomize_content)
  author_email   = var.commit_email
  author_name    = var.commit_author
  commit_message = "Add ${data.flux_sync.main.kustomize_path}"
}
