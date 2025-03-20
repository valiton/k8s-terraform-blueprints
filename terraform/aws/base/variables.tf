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

variable "base_node_group" {
  type = any
  default = {
    base_eks_node = {
      instance_types = ["t4g.medium"]
      ami_type       = "AL2023_ARM_64_STANDARD"
      capacity_type  = "ON_DEMAND"
      min_size       = 1
      max_size       = 3
      desired_size   = 2
      labels = {
        base_nodepool = "base"
      }
    }
  }

  validation {
    condition     = can(coalesce(lookup(var.base_node_group, "base_eks_node", null)))
    error_message = "The 'base_eks_node' key must always exist and cannot be removed or renamed."
  }
}
variable "eks_managed_node_groups" {
  description = "EKS manages nodegroups"
  type        = any
  default     = {}
}
variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.32"
}
variable "addons" {
  description = "Kubernetes addons"
  type        = any
  default = {
    enable_aws_ebs_csi_resources        = true
    enable_metrics_server               = true
    enable_aws_efs_csi_driver           = true
    enable_aws_load_balancer_controller = true
    enable_external_secrets             = true
    enable_external_dns                 = true
    enable_karpenter                    = true
    enable_kube_prometheus_stack        = true
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
  default     = "addon-dependent-resources/vendors/"
}
variable "gitops_workload_path" {
  description = "Git repository path for workload"
  type        = string
  default     = "aws"
}

# external dns
variable "external_dns_domain_filters" {
  description = "Limit possible target zones by domain suffixes."
  type    = string
  default = "['example.org']"
}

variable "route53_zone" {
  description = "Limit possible route53 zones."
  default = "*"
  type    = string
}

# karpenter
#
# aws ssm get-parameter --name "/aws/service/eks/optimized-ami/1.32/amazon-linux-2023/arm64/standard/recommended/image_id" --region eu-central-1 --query "Parameter.Value" --output text
variable "eks_image_arm64" {
  description = "Recommended Amazon Linux AMI ID for AL2023 ARM instances."
  type    = string
  default = "ami-09b9ca376adb3607c"
}

# aws ssm get-parameter --name "/aws/service/eks/optimized-ami/1.32/amazon-linux-2023/x86_64/standard/recommended/image_id" --region eu-central-1 --query "Parameter.Value" --output text
variable "eks_image_x86_64" {
  description = "Recommended Amazon Linux AMI ID for AL2023 x86 based instances."
  type    = string
  default = "ami-0239e3e7b036949c1"
}

