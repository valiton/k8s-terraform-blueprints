variable "environment" {
  default     = "development"
  type        = string
  description = "Infrastructure environment name (e.g. development, staging, production)."
}
variable "base_name" {
  description = "Name of your base infrastructure"
  type        = string
  default     = "my-project"
}
variable "vpc_cidr" {
  description = "VPC CIDR, if empty a random CIDR will be chosen"
  type        = string
  default     = ""
}
variable "azs_count" {
  description = "Number of availability zones"
  type        = number
  default     = 2
}
variable "single_nat_gateway" {
  description = "True if only a single NAT gateway should be deployed instead of one per AZ"
  type        = bool
  default     = false
}
variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "base_node_group_instance_types" {
  type        = list(string)
  default     = ["t4g.medium"]
  description = "List with instance types that are used in the base node group"
}

variable "base_node_group_ami_type" {
  type        = string
  default     = "AL2023_ARM_64_STANDARD"
  description = "AMI type used by the base node group"
}

variable "base_node_group_capacity_type" {
  type        = string
  default     = "ON_DEMAND"
  description = "Capacity types used by the base node group"
}

variable "base_node_group_min_size" {
  type        = number
  default     = 1
  description = "Min instance count of the base node group"
}

variable "base_node_group_max_size" {
  type        = number
  default     = 3
  description = "Max instance count of the base node group"
}

variable "base_node_group_desired_size" {
  type        = number
  default     = 2
  description = "Initial desired instance count of the base node group"
}

variable "base_node_group_labels" {
  type = any
  default = {
    base_nodepool = "base"
  }
  description = "Labels of the base node group"
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
variable "gitops_oss_addons_basepath" {
  description = "Git repository base path for oss specific addons"
  type        = string
  default     = "argocd/addons/"
}
variable "gitops_oss_addons_path" {
  description = "Git repository path for oss specific addons"
  type        = string
  default     = "oss"
}
variable "gitops_oss_addon_config_path" {
  description = "Git repository path for oss specific addon configurations"
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
  description = "Git repository base path for oss specific addon resources"
  type        = string
  default     = "addon-dependent-resources/"
}
variable "gitops_oss_workload_path" {
  description = "Git repository path for oss specific addon resources"
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

# external dns
variable "external_dns_domain_filters" {
  description = "Limit possible target zones by domain suffixes."
  type        = string
  default     = "['example.org']"
}

variable "route53_zone" {
  description = "Limit possible route53 zones."
  default     = "*"
  type        = string
}

# karpenter
#
# aws ssm get-parameter --name "/aws/service/eks/optimized-ami/1.32/amazon-linux-2023/arm64/standard/recommended/image_id" --region eu-central-1 --query "Parameter.Value" --output text
variable "eks_image_arm64" {
  description = "Recommended Amazon Linux AMI ID for AL2023 ARM instances."
  type        = string
  default     = "ami-09b9ca376adb3607c"
}

# aws ssm get-parameter --name "/aws/service/eks/optimized-ami/1.32/amazon-linux-2023/x86_64/standard/recommended/image_id" --region eu-central-1 --query "Parameter.Value" --output text
variable "eks_image_x86_64" {
  description = "Recommended Amazon Linux AMI ID for AL2023 x86 based instances."
  type        = string
  default     = "ami-0239e3e7b036949c1"
}

