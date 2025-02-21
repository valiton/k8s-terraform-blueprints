variable "environment" {
  default = "development"
  type    = string
}
variable "base_name" {
  description = "Name of your base infrastructure"
  type        = string
  default     = "my-project"
}
variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = ""
}
variable "azs_count" {
  type    = number
  default = 2
}
variable "single_nat_gateway" {
  type    = bool
  default = false
}
variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}
variable "eks_managed_node_groups" {
  description = "EKS manages nodegroups"
  type        = any
  default = {
    initial = {
      instance_types = ["t4g.medium"]
      ami_type       = "AL2023_ARM_64_STANDARD"
      capacity_type  = "ON_DEMAND"
      min_size       = 1
      max_size       = 3
      desired_size   = 2
    }
  }
}
variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.32"
}
variable "addons" {
  description = "Kubernetes addons"
  type        = any
  default     =  {
    enable_aws_ebs_csi_resources        = true
    enable_metrics_server               = true
    enable_aws_efs_csi_driver           = true
    enable_aws_load_balancer_controller = true
    enable_external_secrets             = true
    enable_external_dns                 = true
    enable_karpenter                    = true
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
variable "gitops_addons_basepath" {
  description = "Git repository base path for addons"
  type        = string
  default     = "argocd/cluster-addons/"
}
variable "gitops_addons_path" {
  description = "Git repository path for addons"
  type        = string
  default     = "addons"
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
variable "gitops_workload_basepath" {
  description = "Git repository base path for workload"
  type        = string
  default     = "addon-dependent-workload/"
}
variable "gitops_workload_path" {
  description = "Git repository path for workload"
  type        = string
  default     = "addons"
}

# external dns
variable "external_dns_domain_filters" {
  type    = string
  default = "['example.org']"
}

variable "route53_zone" {
  default = "*"
  type    = string
}

