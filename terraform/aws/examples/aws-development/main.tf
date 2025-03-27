module "base" {
  source = "git::git@github.com:valiton/k8s-terraform-blueprints.git//terraform/aws/base?ref=main"
 
  # Identifier for EKS cluster and other resources
  base_name = "eks-development-example"

  # K8s configurations will select the configs for this environment
  environment = "development"

  # use only single NAT gateway for cost savings for all AZs
  single_nat_gateway = 1
}
