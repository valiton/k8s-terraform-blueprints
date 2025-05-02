variable "environment" {
  default     = "development"
  type        = string
  description = "Infrastructure environment name (e.g. development, staging, production)."
}

variable "base_name" {
  description = "Name of your base infrastructure."
  type        = string
  default     = "my-project"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.base_name))
    error_message = "The base_name must only contain lowercase letters, numbers, and dashes."
  }
}

variable "os_public_network_name" {
  description = "Name of the Openstack public network"
  default     = "Public1"
}

variable "os_private_network_name" {
  description = "Name of the private network, will be prefixed with base_name"
  default     = "private-network"
}

variable "os_private_network_cidr" {
  description = "Private network CIDR, if empty a random CIDR will be chosen, 10.244.0.0/16 and 10.96.0.0/12 are used by Talos."
  type        = string
  default     = ""
}
variable "os_auth_url" {
  description = "Openstack keystone url"
  default     = "https://dashboard.bws.burda.com:5000"
}

variable "os_application_credential_id" {
  description = "Openstack application credentials ID"
  default     = ""
}

variable "os_application_credential_secret" {
  description = "Openstack application credentials secret"
  default     = ""
}

variable "os_user_name" {
  description = "Openstack user name"
  default     = ""
}

variable "talos_secrets" {
  description = "Object of secrets generated with talosctl gen secrets"
}

variable "worker_instance_flavor" {
  description = "Instance flavor for worker nodes"
  default     = "BWS-T1-2-4"
}

variable "worker_volume_type" {
  description = "BWS volume type for worker nodes"
  default     = "ssd-10000-250"
}

variable "worker_volume_size" {
  description = "Size in GB of the disk of worker nodes"
  default     = 40
}

variable "controlplane_instance_flavor" {
  description = "Instance flavor for controlplane nodes"
  default     = "BWS-T1-2-4"
}

variable "controlplane_volume_type" {
  description = "BWS volume type for controlplane nodes"
  default     = "ssd-10000-250"
}

variable "controlplane_volume_size" {
  description = "Size in GB of the disk of controlplane nodes"
  default     = 40
}

variable "image_name" {
  description = "Name of the Talos image in your BWS project"
  default     = "Talos"
}

variable "kube_api_external_ip" {
  description = "External floating IP to expose Kubernetes API"
  type        = string
  default     = "1.2.3.4"
}

variable "kube_api_external_port" {
  description = "Port to expose Kubernetes API"
  type        = number
  default     = 6443
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "v1.32.3"
}

variable "openstack_ccm_version" {
  description = "Openstack cloud controller mananger version"
  type        = string
  default     = "v1.32.0"
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}

variable "controlplane_count" {
  description = "Number of controlplane nodes"
  type        = number
  default     = 3
}

variable "addons" {
  description = "Kubernetes addons"
  type        = any
  default = {
    enable_metrics_server               = true
    enable_external_secrets             = true
    enable_external_dns                 = true
    enable_kube_prometheus_stack        = true
    enable_cinder_csi_plugin            = true
    enable_ingress_nginx                = true
    enable_cert_manager                 = true
    enable_cert_manager_dns01_designate = true
  }
}

# Addons Git
variable "gitops_addons_org" {
  description = "Git repository org/user contains for addons"
  type        = string
  default     = "https://github.com/valiton"
}

variable "gitops_addons_repo" {
  description = "Git repository contains for addons"
  type        = string
  default     = "k8s-terraform-blueprints"
}

variable "gitops_addons_revision" {
  description = "Git repository revision/branch/ref for addons"
  type        = string
  default     = "main"
}

variable "gitops_oss_addons_basepath" {
  description = "Git repository base path for oss addons"
  type        = string
  default     = "argocd/addons/"
}

variable "gitops_oss_addons_path" {
  description = "Git repository path for oss addons"
  type        = string
  default     = "oss"
}

variable "gitops_oss_addon_config_path" {
  description = "Git repository path for oss addon configurations"
  type        = string
  default     = "argocd/addons/config/oss"
}

variable "gitops_vendor_addons_basepath" {
  description = "Git repository base path for vendor specific addons"
  type        = string
  default     = "argocd/addons/vendors/"
}

variable "gitops_vendor_addons_path" {
  description = "Git repository path for vendor specific addons"
  type        = string
  default     = "bws"
}

variable "gitops_vendor_addon_config_path" {
  description = "Git repository path for vendor specific addon configurations"
  type        = string
  default     = "argocd/addons/config/vendors/bws"
}

# Workloads Git
variable "gitops_workload_org" {
  description = "Git repository org/user contains for workload"
  type        = string
  default     = "https://github.com/valiton"
}

variable "gitops_workload_repo" {
  description = "Git repository contains for workload"
  type        = string
  default     = "k8s-terraform-blueprints"
}

variable "gitops_workload_revision" {
  description = "Git repository revision/branch/ref for workload"
  type        = string
  default     = "main"
}

variable "gitops_oss_workload_basepath" {
  description = "Git repository base path for oss addon resources"
  type        = string
  default     = "addon-dependent-resources/"
}

variable "gitops_oss_workload_path" {
  description = "Git repository path for oss addon resources"
  type        = string
  default     = "oss"
}

variable "gitops_vendor_workload_basepath" {
  description = "Git repository base path for vendor specific addon resources"
  type        = string
  default     = "addon-dependent-resources/vendors/"
}

variable "gitops_vendor_workload_path" {
  description = "Git repository path for vendor specific addon resources"
  type        = string
  default     = "bws"
}

# external dns
variable "external_dns" {
  description = "External DNS add-on configuration values"
  type        = any
  default = {
    domain_filters = "[example.com]"
  }
}

variable "external_secrets" {
  description = "External Secrets add-on configuration values"
  type        = any
  default     = {}
}

variable "ingress_nginx" {
  description = "Ingress Nginx add-on configuration values"
  type        = any
  default     = {}
}

variable "kube_prometheus_stack" {
  description = "Kube prometheus stack add-on configuration values"
  type        = any
  default     = {}
}

variable "cinder_csi_plugin" {
  description = "Cinder csi plugin add-on configuration values"
  type        = any
  default     = {}
}

variable "cert_manager" {
  description = "Cert manager add-on configuration values"
  type        = any
  default = {
    acme = {
      registration_email = ""
    }
  }
}

variable "cert_manager_dns01_designate" {
  description = "Cert manager webhook for ACME DNS-01 challenge with Designate"
  type        = any
  default     = {}
}
