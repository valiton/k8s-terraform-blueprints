data "aws_caller_identity" "current" {}

locals {
  region = var.region

  environment = var.environment

  vpc_id = var.vpc_id

  cluster_name        = var.eks_cluster_name
  cluster_endpoint    = var.eks_cluster_endpoint
  cluster_version     = var.eks_cluster_version
  oidc_provider_arn   = var.eks_oidc_provider_arn
  managed_node_groups = var.eks_managed_node_groups
  eks_image_arm64     = var.eks_image_arm64
  eks_image_x86_64    = var.eks_image_x86_64

  external_dns_domain_filters = var.external_dns_domain_filters

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

  aws_addons = {
    enable_aws_efs_csi_driver           = try(var.addons.enable_aws_efs_csi_driver, false)
    enable_external_dns                 = try(var.addons.enable_external_dns, false)
    enable_external_secrets             = try(var.addons.enable_external_secrets, false)
    enable_aws_load_balancer_controller = try(var.addons.enable_aws_load_balancer_controller, false)
    enable_karpenter                    = try(var.addons.enable_karpenter, false)
    enable_aws_ebs_csi_resources        = try(var.addons.enable_aws_ebs_csi_resources, false)
  }

  oss_addons = {
    enable_argocd = try(var.addons.enable_argocd, true)
    #enable_argo_rollouts                   = try(var.addons.enable_argo_rollouts, false)
    #enable_argo_events                     = try(var.addons.enable_argo_events, false)
    #enable_argo_workflows                  = try(var.addons.enable_argo_workflows, false)
    #enable_ingress_nginx                   = try(var.addons.enable_ingress_nginx, false)
    enable_kube_prometheus_stack = try(var.addons.enable_kube_prometheus_stack, false)
    enable_metrics_server        = try(var.addons.enable_metrics_server, false)
    #enable_prometheus_adapter              = try(var.addons.enable_prometheus_adapter, false)
  }

  addons = merge(
    local.aws_addons,
    local.oss_addons,
    { kubernetes_version = local.cluster_version },
    { aws_cluster_name = local.cluster_name }
  )

  addons_metadata = merge(
    module.eks_blueprints_addons.gitops_metadata,
    {
      external_dns_domain_filters = local.external_dns_domain_filters
      aws_cluster_name            = local.cluster_name
      aws_region                  = local.region
      aws_account_id              = data.aws_caller_identity.current.account_id
      aws_vpc_id                  = local.vpc_id
      base_nodepool_labels        = jsonencode(local.managed_node_groups["base_eks_node"].node_group_labels)
      eks_image_arm64             = local.eks_image_arm64
      eks_image_x86_64            = local.eks_image_x86_64
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
    }
  )

  argocd_apps = {
    vendor-addons    = file("${path.module}/argocd/vendor-addons.yaml")
    oss-addons       = file("${path.module}/argocd/oss-addons.yaml")
    vendor-workloads = file("${path.module}/argocd/vendor-workloads.yaml")
    oss-workloads    = file("${path.module}/argocd/oss-workloads.yaml")
  }

  tags = {
    Blueprint  = local.cluster_name
    GithubRepo = "github.com/valiton/k8s-terraform-blueprints"
  }
}

################################################################################
# GitOps Bridge: Bootstrap
################################################################################
module "gitops_bridge_bootstrap" {
  source  = "git::https://github.com/valiton-k8s-blueprints/terraform-helm-gitops-bridge?ref=main"

  cluster = {
    cluster_name = local.cluster_name
    environment  = local.environment
    metadata     = local.addons_metadata
    addons       = local.addons
  }

  apps = local.argocd_apps
}

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "1.21.0" #ensure to update this to the latest/desired version

  cluster_name      = local.cluster_name
  cluster_endpoint  = local.cluster_endpoint
  cluster_version   = local.cluster_version
  oidc_provider_arn = local.oidc_provider_arn

  # Using GitOps Bridge
  create_kubernetes_resources = false

  # EKS Blueprints Addons
  enable_aws_efs_csi_driver           = local.aws_addons.enable_aws_efs_csi_driver
  enable_external_dns                 = local.aws_addons.enable_external_dns
  external_dns_route53_zone_arns      = [var.route53_zone]
  enable_external_secrets             = local.aws_addons.enable_external_secrets
  enable_aws_load_balancer_controller = local.aws_addons.enable_aws_load_balancer_controller
  enable_karpenter                    = local.aws_addons.enable_karpenter

  karpenter_node = {
    # Use static name so that it matches what is defined in `karpenter.yaml` example manifest
    iam_role_use_name_prefix     = false
    iam_role_additional_policies = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
  }

}

module "aws_auth" {
  source = "terraform-aws-modules/eks/aws//modules/aws-auth"
  manage_aws_auth_configmap = true
  aws_auth_roles = [
    {
      rolearn  = module.eks_blueprints_addons.karpenter.node_iam_role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    },
  ]

  depends_on = [
    module.gitops_bridge_bootstrap,
  ]
}
