
variable "environment" {
  default     = "development"
  type        = string
  description = "Infrastructure environment name (e.g. development, staging, production)."
}
variable "region" {
  description = "STACKIT region"
  type        = string
  default     = "eu01"
}
variable "project_id" {
  type        = string
  description = "STACKIT project ID to which the cluster is associated."
}
variable "ske_cluster_name" {
  description = "Name of the SKE cluster"
  type        = string
}
variable "ske_cluster_id" {
  description = "Internal ID of the SKE cluster"
  type        = string
}
variable "ske_cluster_version" {
  description = "Kubernetes version to use for the SKE cluster"
  type        = string
}
variable "ske_egress_adress_range" {
  description = "Egress IP range of the clusters"
  type        = string
}
variable "ske_nodepools" {
  description = "Map of attribute maps for all SKE managed node pools."
  type        = any
}


variable "addons" {
  description = "Kubernetes addons"
  type        = any
  default = {
    enable_ingress_nginx         = true
    enable_cert_manager          = true
    enable_kube_prometheus_stack = true
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
  default     = "aws"
}
variable "gitops_vendor_addon_config_path" {
  description = "Git repository path for vendor specific addon configurations"
  type        = string
  default     = "argocd/addons/config/vendors/aws"
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
  default     = "aws"
}

