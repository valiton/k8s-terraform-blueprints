locals {
  region = var.region

  environment = var.environment

  project_id = var.project_id

  ske_cluster_name        = var.ske_cluster_name
  ske_cluster_id          = var.ske_cluster_id
  ske_egress_adress_range = var.ske_egress_adress_range
  ske_cluster_version     = var.ske_cluster_version
  ske_nodepools           = var.ske_nodepools

  gitops_addons_url               = "${var.gitops_addons_org}/${var.gitops_addons_repo}"
  gitops_addons_revision          = var.gitops_addons_revision
  gitops_vendor_addons_basepath   = var.gitops_vendor_addons_basepath
  gitops_vendor_addons_path       = var.gitops_vendor_addons_path
  gitops_vendor_addon_config_path = var.gitops_vendor_addon_config_path
  gitops_oss_addons_basepath      = var.gitops_oss_addons_basepath
  gitops_oss_addons_path          = var.gitops_oss_addons_path
  gitops_oss_addon_config_path    = var.gitops_oss_addon_config_path


  gitops_workload_url             = "${var.gitops_workload_org}/${var.gitops_workload_repo}"
  gitops_workload_revision        = var.gitops_workload_revision
  gitops_vendor_workload_basepath = var.gitops_vendor_workload_basepath
  gitops_vendor_workload_path     = var.gitops_vendor_workload_path
  gitops_oss_workload_basepath    = var.gitops_oss_workload_basepath
  gitops_oss_workload_path        = var.gitops_oss_workload_path

  ske_addons = {
    enable_argocd                = try(var.addons.enable_argocd, true)
    enable_ingress_nginx         = try(var.addons.enable_ingress_nginx, false)
    enable_cert_manager          = try(var.addons.enable_cert_manager, false)
    enable_kube_prometheus_stack = try(var.addons.enable_kube_prometheus_stack, false)
  }


  addons = merge(
    local.ske_addons,
    { kubernetes_version = local.ske_cluster_version },
  )

  addons_metadata = merge(
    {
      ske_cluster_name     = local.ske_cluster_name
      region               = local.region
      project_id           = local.project_id
      base_nodepool_labels = jsonencode(local.ske_nodepools[0].labels)
    },
    {
      addons_repo_url             = local.gitops_addons_url
      addons_repo_revision        = local.gitops_addons_revision
      vendor_addons_repo_basepath = local.gitops_vendor_addons_basepath
      vendor_addons_repo_path     = local.gitops_vendor_addons_path
      vendor_addon_config_path    = local.gitops_vendor_addon_config_path
      oss_addons_repo_basepath    = local.gitops_oss_addons_basepath
      oss_addons_repo_path        = local.gitops_oss_addons_path
      oss_addon_config_path       = local.gitops_oss_addon_config_path
    },
    {
      workload_repo_url             = local.gitops_workload_url
      workload_repo_revision        = local.gitops_workload_revision
      vendor_workload_repo_basepath = local.gitops_vendor_workload_basepath
      vendor_workload_repo_path     = local.gitops_vendor_workload_path
      oss_workload_repo_basepath    = local.gitops_oss_workload_basepath
      oss_workload_repo_path        = local.gitops_oss_workload_path
    }

  )

  argocd_apps = {
    vendor-addons    = file("${path.module}/argocd/vendor-addons.yaml")
    oss-addons       = file("${path.module}/argocd/oss-addons.yaml")
    vendor-workloads = file("${path.module}/argocd/vendor-workloads.yaml")
    oss-workloads    = file("${path.module}/argocd/oss-workloads.yaml")
  }
}

################################################################################
# GitOps Bridge: Bootstrap
################################################################################
module "gitops_bridge_bootstrap" {
  source = "git::https://github.com/valiton-k8s-blueprints/terraform-helm-gitops-bridge?ref=main"

  cluster = {
    cluster_name = local.ske_cluster_name
    environment  = local.environment
    metadata     = local.addons_metadata
    addons       = local.addons
  }

  apps = local.argocd_apps
}
