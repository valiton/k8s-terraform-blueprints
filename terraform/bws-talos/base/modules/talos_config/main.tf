locals {
  config_patches = [
    templatefile(
      "${path.module}/talos_config_patches/custom_ca.yaml",
      {
        ca_cert = var.custom_ca_cert
      }
    ),
    templatefile(
      "${path.module}/talos_config_patches/openstack_ccm_config.yaml",
      {
        os_ccm_version                   = var.os_ccm_version
        os_auth_url                      = var.os_auth_url
        os_application_credential_id     = var.os_application_credential_id
        os_application_credential_secret = var.os_application_credential_secret
        os_floating_network_id           = var.public_network_id
        os_subnet_id                     = var.private_network_subnet_id
      }
    ),
    templatefile(
      "${path.module}/talos_config_patches/machine_config.yaml",
      {
        endpoint = var.cluster_endpoint
      }
    )
  ]
}

resource "talos_machine_secrets" "talos" {}

data "talos_machine_configuration" "controlplane" {
  cluster_name       = var.cluster_name
  cluster_endpoint   = "https://${var.cluster_endpoint}"
  machine_type       = "controlplane"
  machine_secrets    = talos_machine_secrets.talos.machine_secrets
  kubernetes_version = var.kubernetes_version

  config_patches = local.config_patches
}

data "talos_machine_configuration" "worker" {
  cluster_name       = var.cluster_name
  cluster_endpoint   = "https://${var.cluster_endpoint}"
  machine_type       = "worker"
  machine_secrets    = talos_machine_secrets.talos.machine_secrets
  kubernetes_version = var.kubernetes_version

  config_patches = local.config_patches
}

data "talos_client_configuration" "talos" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.talos.client_configuration
  endpoints            = [var.cluster_endpoint]
}

