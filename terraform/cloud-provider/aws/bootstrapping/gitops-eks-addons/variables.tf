
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
