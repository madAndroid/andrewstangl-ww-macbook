locals {
  flux_target_path    = "${var.target_path}/${var.flux_sync_directory}"
  gitlab_hostname     = replace(var.gitlab_url, "/(https?://)/", "")
  cluster_admin_users = split(",", var.cluster_admin_users_string)
  cluster_admin_roles = split(",", var.cluster_admin_roles_string)
}
