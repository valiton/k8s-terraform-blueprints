locals {
  kubernetes_endpoint = "https://${var.kube_api_external_ip}:${var.kube_api_external_port}"
  talos_secrets       = yamldecode(file(var.talos_secrets_file))
}

provider "openstack" {
  auth_url                      = var.os_auth_url
  application_credential_id     = var.os_application_credential_id
  application_credential_secret = var.os_application_credential_secret
}

provider "helm" {
  kubernetes {
    host                   = local.kubernetes_endpoint
    token                  = data.openstack_identity_auth_scope_v3.user.token_id
    cluster_ca_certificate = base64decode(local.talos_secrets.certs.k8s.crt)
  }
}

provider "kubernetes" {
  host                   = local.kubernetes_endpoint
  token                  = data.openstack_identity_auth_scope_v3.user.token_id
  cluster_ca_certificate = base64decode(local.talos_secrets.certs.k8s.crt)
}

data "openstack_identity_auth_scope_v3" "user" {
  name         = "user"
  set_token_id = true
}

module "bws-talos" {
  source = "../base"

  base_name                        = var.base_name
  os_auth_url                      = var.os_auth_url
  os_application_credential_id     = var.os_application_credential_id
  os_application_credential_secret = var.os_application_credential_secret
  os_user_name                     = data.openstack_identity_auth_scope_v3.user.user_name
  kube_api_external_ip             = var.kube_api_external_ip
  kube_api_external_port           = var.kube_api_external_port
  talos_secrets                    = local.talos_secrets

  worker_instance_flavor       = "BWS-T1-4-16"
  controlplane_instance_flavor = "BWS-T1-4-16"

  external_dns = {
    domain_filters = var.external_dns_domain_filters
    policy         = "sync"
  }

  cert_manager = {
    acme = {
      registration_email = var.cert_manager_acme_registration_mail
    }
  }

  ingress_nginx = {
    ingressclass = {
      name    = "ingress-nginx"
      default = "true"
    }
  }
}
