resource "random_integer" "ip_part" {
  # prevent overlap with 10.96.0.0/12
  min = 112
  # prevent overlap with 10.244.0.0/16
  max = 243
}

locals {
  name                            = var.base_name
  cluster_version                 = var.kubernetes_version
  private_network_cidr            = var.os_private_network_cidr != "" ? var.os_private_network_cidr : "10.${random_integer.ip_part.result}.0.0/16"
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

  oss_addons = {
    enable_argocd                          = try(var.addons.enable_argocd, true)
    enable_argo_rollouts                   = try(var.addons.enable_argo_rollouts, false)
    enable_argo_events                     = try(var.addons.enable_argo_events, false)
    enable_argo_workflows                  = try(var.addons.enable_argo_workflows, false)
    enable_cluster_proportional_autoscaler = try(var.addons.enable_cluster_proportional_autoscaler, false)
    enable_gatekeeper                      = try(var.addons.enable_gatekeeper, false)
    enable_gpu_operator                    = try(var.addons.enable_gpu_operator, false)
    enable_ingress_nginx                   = try(var.addons.enable_ingress_nginx, false)
    enable_keda                            = try(var.addons.enable_keda, false)
    enable_kyverno                         = try(var.addons.enable_kyverno, false)
    enable_kube_prometheus_stack           = try(var.addons.enable_kube_prometheus_stack, false)
    enable_metrics_server                  = try(var.addons.enable_metrics_server, false)
    enable_prometheus_adapter              = try(var.addons.enable_prometheus_adapter, false)
    enable_secrets_store_csi_driver        = try(var.addons.enable_secrets_store_csi_driver, false)
    enable_vpa                             = try(var.addons.enable_vpa, false)
  }

  addons = merge(
    local.oss_addons,
    { kubernetes_version = local.cluster_version },
  )

  addons_metadata = merge(
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

  tags = {
    Blueprint  = local.name
    GithubRepo = "github.com/valiton/k8s-terraform-blueprints"
  }

  client_configuration = {
    ca_certificate     = var.talos_secrets.certs.os.crt
    client_certificate = base64encode(module.talos-config.talos_client_crt)
    client_key         = base64encode(module.talos-config.talos_client_key)
  }
}

################################################################################
# GitOps Bridge: Bootstrap
################################################################################
module "gitops_bridge_bootstrap" {
  source = "gitops-bridge-dev/gitops-bridge/helm"

  depends_on = [data.talos_cluster_health.talos]

  cluster = {
    cluster_name = var.base_name
    environment  = var.environment
    metadata     = local.addons_metadata
    addons       = local.addons
  }

  apps = local.argocd_apps
}

################################################################################
# Openstack network setup
################################################################################
module "network" {
  source = "./modules/network"

  name_prefix             = var.base_name
  os_public_network_name  = var.os_public_network_name
  os_private_network_name = var.os_private_network_name
  os_private_network_cidr = local.private_network_cidr
  worker_count            = var.worker_count
  controlplane_count      = var.controlplane_count
  kube_api_external_ip    = var.kube_api_external_ip
  kube_api_external_port  = var.kube_api_external_port
}

################################################################################
# Talos config setup
################################################################################
module "talos-config" {
  source = "./modules/talos_config"

  cluster_name                     = var.base_name
  talos_secrets                    = var.talos_secrets
  kube_api_external_ip             = var.kube_api_external_ip
  kube_api_external_port           = var.kube_api_external_port
  kubernetes_version               = var.kubernetes_version
  os_ccm_version                   = var.openstack_ccm_version
  os_auth_url                      = var.os_auth_url
  os_application_credential_id     = var.os_application_credential_id
  os_application_credential_secret = var.os_application_credential_secret
  os_user_name                     = var.os_user_name
  public_network_id                = module.network.public_network_id
  private_network_subnet_id        = module.network.private_network_subnet_id
}

module "instances" {
  source = "./modules/instances"

  name_prefix                  = var.base_name
  worker_count                 = var.worker_count
  controlplane_count           = var.controlplane_count
  image_name                   = var.image_name
  worker_instance_flavor       = var.worker_instance_flavor
  worker_volume_type           = var.worker_volume_type
  worker_volume_size           = var.worker_volume_size
  worker_port_id               = module.network.worker_port_id
  worker_user_data             = module.talos-config.worker_machine_configuration
  controlplane_instance_flavor = var.controlplane_instance_flavor
  controlplane_volume_type     = var.controlplane_volume_type
  controlplane_volume_size     = var.controlplane_volume_size
  controlplane_port_id         = module.network.controlplane_port_id
  controlplane_user_data       = module.talos-config.controlplane_machine_configuration
}

resource "null_resource" "boostrap_trigger" {
  triggers = {
    controlplane_instance = module.talos-config.controlplane_machine_configuration
  }
}

########################
# Boostrap cluster
#################
resource "talos_machine_bootstrap" "cluster" {
  depends_on = [
    module.network,
    module.instances,
  ]

  client_configuration = local.client_configuration

  node     = module.network.controlplane_fixed_ips[0]
  endpoint = var.kube_api_external_ip

  lifecycle {
    replace_triggered_by = [
      null_resource.boostrap_trigger
    ]
  }
}

data "talos_cluster_health" "talos" {
  depends_on = [talos_machine_bootstrap.cluster]

  client_configuration = local.client_configuration

  control_plane_nodes = module.network.controlplane_fixed_ips
  worker_nodes        = module.network.worker_fixed_ips
  endpoints           = [var.kube_api_external_ip]
}

data "talos_client_configuration" "talos" {
  cluster_name         = var.base_name
  client_configuration = local.client_configuration
  endpoints            = [var.kube_api_external_ip]
}
