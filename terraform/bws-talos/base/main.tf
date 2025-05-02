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

  external_secrets_namespace      = try(var.external_secrets.namespace, "external-secrets")
  kube_prometheus_stack_namespace = try(var.kube_prometheus_stack.namespace, "kube-prometheus-stack")
  cinder_csi_plugin_namespace     = try(var.cinder_csi_plugin.namespace, "cinder-csi-plugin")
  cinder_csi_plugin_secret_name   = try(var.cinder_csi_plugin.secret.name, "cinder-csi-plugin-secret")

  external_dns_namespace             = try(var.external_dns.namespace, "external-dns")
  external_dns_domain_filters        = try(var.external_dns.domain_filters, "")
  external_dns_policy                = try(var.external_dns.policy, "")
  external_dns_designate_cloud_name  = try(var.external_dns.designate.cloud_name, "cloud")
  external_dns_designate_secret_name = try(var.external_dns.designate.secret_name, "external-dns-designate-secret")

  ingress_nginx_namespace            = try(var.ingress_nginx.namespace, "ingress-nginx")
  ingress_nginx_ingressclass_name    = try(var.ingress_nginx.ingressclass.name, "nginx")
  ingress_nginx_ingressclass_default = try(var.ingress_nginx.ingressclass.default, "")

  cert_manager_namespace               = try(var.cert_manager.namespace, "cert-manager")
  cert_manager_service_account_name    = try(var.cert_manager.service_account_name, "cert-manager")
  cert_manager_acme_registration_email = try(var.cert_manager.acme.registration_email, "")

  cert_manager_dns01_designate_namespace   = try(var.cert_manager_dns01_designate.namespace, "cert-manager-dns01-designate")
  cert_manager_dns01_designate_secret_name = try(var.cert_manager_dns01_designate.secret_name, "designate-auth")

  bws_addons = {
    enable_cinder_csi_plugin            = try(var.addons.enable_cinder_csi_plugin, false)
    enable_external_dns                 = try(var.addons.enable_external_dns, false)
    enable_ingress_nginx                = try(var.addons.enable_ingress_nginx, false)
    enable_cert_manager                 = try(var.addons.enable_cert_manager, false) || try(var.addons.enable_cert_manager_dns01_designate, false)
    enable_cert_manager_dns01_designate = try(var.addons.enable_cert_manager_dns01_designate, false)
  }

  oss_addons = {
    enable_argocd                = try(var.addons.enable_argocd, true)
    enable_external_secrets      = try(var.addons.enable_external_secrets, false) || local.bws_addons.enable_cinder_csi_plugin || local.bws_addons.enable_external_dns || local.bws_addons.enable_cert_manager_dns01_designate
    enable_kube_prometheus_stack = try(var.addons.enable_kube_prometheus_stack, false)
    enable_metrics_server        = try(var.addons.enable_metrics_server, false)
  }

  addons = merge(
    local.oss_addons,
    local.bws_addons,
    { kubernetes_version = local.cluster_version },
  )

  addons_metadata = merge(
    {
      external_secrets_namespace = local.external_secrets_namespace

      kube_prometheus_stack_namespace = local.kube_prometheus_stack_namespace

      cinder_csi_plugin_namespace   = local.cinder_csi_plugin_namespace
      cinder_csi_plugin_secret_name = local.cinder_csi_plugin_secret_name
      enable_cinder_csi_plugin      = local.bws_addons.enable_cinder_csi_plugin ? "true" : "false"

      external_dns_namespace             = local.external_dns_namespace
      external_dns_domain_filters        = local.external_dns_domain_filters
      external_dns_policy                = local.external_dns_policy
      external_dns_designate_cloud_name  = local.external_dns_designate_cloud_name
      external_dns_designate_secret_name = local.external_dns_designate_secret_name
      enable_external_dns                = local.bws_addons.enable_external_dns ? "true" : "false"

      ingress_nginx_namespace            = local.ingress_nginx_namespace
      ingress_nginx_ingressclass_name    = local.ingress_nginx_ingressclass_name
      ingress_nginx_ingressclass_default = local.ingress_nginx_ingressclass_default
      enable_ingress_nginx               = local.bws_addons.enable_ingress_nginx ? "true" : "false"

      cert_manager_namespace                   = local.cert_manager_namespace
      cert_manager_service_account_name        = local.cert_manager_service_account_name
      cert_manager_acme_registration_email     = local.cert_manager_acme_registration_email
      cert_manager_dns01_designate_namespace   = local.cert_manager_dns01_designate_namespace
      cert_manager_dns01_designate_secret_name = local.cert_manager_dns01_designate_secret_name
      enable_cert_manager_dns01_designate      = local.bws_addons.enable_cert_manager_dns01_designate
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
    },
    {
      cluster_secret_namespace       = module.cluster_secrets.namepace
      cluster_secret_name            = module.cluster_secrets.secret_name
      cluster_secret_service_account = module.cluster_secrets.service_account
      openstack_auth_url             = var.os_auth_url
      openstack_subnet_id            = module.network.private_network_subnet_id
      openstack_floating_network_id  = module.network.public_network_id
    }
  )

  argocd_apps = {
    vendor-addons    = file("${path.module}/argocd/vendor-addons.yaml")
    oss-addons       = file("${path.module}/argocd/oss-addons.yaml")
    vendor-workloads = file("${path.module}/argocd/vendor-workloads.yaml")
    oss-workloads    = file("${path.module}/argocd/oss-workloads.yaml")
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
  source = "git::https://github.com/valiton-k8s-blueprints/terraform-helm-gitops-bridge.git?ref=main"

  depends_on = [data.talos_cluster_health.talos, module.cluster_secrets]

  cluster = {
    cluster_name = var.base_name
    environment  = var.environment
    metadata     = local.addons_metadata
    addons       = local.addons
  }

  apps = local.argocd_apps

  argocd = {
    chart_version = "7.8.26"
    values = [
      yamlencode({
        configs = {
          cm = {
            "application.resourceTrackingMethod"                     = "annotation"
            "resource.customizations.health.argoproj.io_Application" = <<-EOF
            hs = {}
            hs.status = "Progressing"
            hs.message = ""
            if obj.status ~= nil then
              if obj.status.health ~= nil then
                hs.status = obj.status.health.status
                if obj.status.health.message ~= nil then
                  hs.message = obj.status.health.message
                end
              end
            end
            return hs
EOF
          }
        }
      })
    ]
  }

  destroy_timeout = 180
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

  pod_security_exemptions_namespaces = compact([
    local.oss_addons.enable_kube_prometheus_stack ? local.kube_prometheus_stack_namespace : "",
    local.bws_addons.enable_cinder_csi_plugin ? local.cinder_csi_plugin_namespace : ""
  ])
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
}

############################
# Apply Talos configuration
############################
resource "talos_machine_configuration_apply" "controlplane" {
  count = var.controlplane_count

  depends_on = [
    module.network,
    module.instances
  ]

  client_configuration = local.client_configuration
  endpoint             = var.kube_api_external_ip
  node                 = module.network.controlplane_fixed_ips[count.index]

  machine_configuration_input = module.talos-config.controlplane_machine_configuration
}

resource "talos_machine_configuration_apply" "worker" {
  count = var.worker_count

  depends_on = [talos_machine_configuration_apply.controlplane]

  client_configuration = local.client_configuration
  endpoint             = var.kube_api_external_ip
  node                 = module.network.worker_fixed_ips[count.index]

  machine_configuration_input = module.talos-config.worker_machine_configuration
}

########################
# Boostrap cluster
########################
resource "talos_machine_bootstrap" "cluster" {
  depends_on = [
    module.network,
    module.instances,
    talos_machine_configuration_apply.controlplane,
    talos_machine_configuration_apply.worker
  ]

  client_configuration = local.client_configuration

  node     = module.network.controlplane_fixed_ips[0]
  endpoint = var.kube_api_external_ip
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

module "cluster_secrets" {
  depends_on = [data.talos_cluster_health.talos]

  source = "./modules/cluster_secrets"

  os_application_credential_id     = var.os_application_credential_id
  os_application_credential_secret = var.os_application_credential_secret
}
