# Terraform AWS Base Module

## Overview
This Terraform module sets up foundational AWS infrastructure, providing a base for deploying workloads on AWS. It follows best practices to ensure security, scalability, and maintainability.

## Features
- Creates a **VPC** with public and private subnets
- Creates an **EKS** cluster
- Configures **IAM roles and policies**
- Deploys **EC2 instances, security groups, and networking components** that are required to run the tooling services

This setup does not contain any application specific requirements. It focuses simply on Layer 1 and 2 that contains the VPC, EKS and tooling applications for proper monitoring, alerting, scaling, secret handling and DNS handling. 

## Usage
To use this module, include the following in your Terraform configuration:

```hcl
module "base" {
  source = "git::git@github.com:valiton/k8s-terraform-blueprints.git//terraform/aws/base?ref=main"
  
  base_name = "my_project"
  
  # Additional configuration...
}
```
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.67.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.10.1 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | 2.22.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.67.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ebs_csi_driver_irsa"></a> [ebs\_csi\_driver\_irsa](#module\_ebs\_csi\_driver\_irsa) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | ~> 5.54 |
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/eks/aws | ~> 19.13 |
| <a name="module_eks_blueprints_addons"></a> [eks\_blueprints\_addons](#module\_eks\_blueprints\_addons) | aws-ia/eks-blueprints-addons/aws | ~> 1.20.0 |
| <a name="module_gitops_bridge_bootstrap"></a> [gitops\_bridge\_bootstrap](#module\_gitops\_bridge\_bootstrap) | gitops-bridge-dev/gitops-bridge/helm | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modules/vpc/aws | ~> 5.19 |

## Resources

| Name | Type |
|------|------|
| [random_integer.ip_part](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/integer) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addons"></a> [addons](#input\_addons) | Kubernetes addons | `any` | <pre>{<br/>  "enable_aws_ebs_csi_resources": true,<br/>  "enable_aws_efs_csi_driver": true,<br/>  "enable_aws_load_balancer_controller": true,<br/>  "enable_external_dns": true,<br/>  "enable_external_secrets": true,<br/>  "enable_karpenter": true,<br/>  "enable_kube_prometheus_stack": true,<br/>  "enable_metrics_server": true<br/>}</pre> | no |
| <a name="input_azs_count"></a> [azs\_count](#input\_azs\_count) | Number of availability zones | `number` | `2` | no |
| <a name="input_base_name"></a> [base\_name](#input\_base\_name) | Name of your base infrastructure | `string` | `"my-project"` | no |
| <a name="input_base_node_group_ami_type"></a> [base\_node\_group\_ami\_type](#input\_base\_node\_group\_ami\_type) | AMI type used by the base node group | `string` | `"AL2023_ARM_64_STANDARD"` | no |
| <a name="input_base_node_group_capacity_type"></a> [base\_node\_group\_capacity\_type](#input\_base\_node\_group\_capacity\_type) | Capacity types used by the base node group | `string` | `"ON_DEMAND"` | no |
| <a name="input_base_node_group_desired_size"></a> [base\_node\_group\_desired\_size](#input\_base\_node\_group\_desired\_size) | Initial desired instance count of the base node group | `number` | `2` | no |
| <a name="input_base_node_group_instance_types"></a> [base\_node\_group\_instance\_types](#input\_base\_node\_group\_instance\_types) | List with instance types that are used in the base node group | `list(string)` | <pre>[<br/>  "t4g.medium"<br/>]</pre> | no |
| <a name="input_base_node_group_labels"></a> [base\_node\_group\_labels](#input\_base\_node\_group\_labels) | Labels of the base node group | `any` | <pre>{<br/>  "base_nodepool": "base"<br/>}</pre> | no |
| <a name="input_base_node_group_max_size"></a> [base\_node\_group\_max\_size](#input\_base\_node\_group\_max\_size) | Max instance count of the base node group | `number` | `3` | no |
| <a name="input_base_node_group_min_size"></a> [base\_node\_group\_min\_size](#input\_base\_node\_group\_min\_size) | Min instance count of the base node group | `number` | `1` | no |
| <a name="input_eks_image_arm64"></a> [eks\_image\_arm64](#input\_eks\_image\_arm64) | Recommended Amazon Linux AMI ID for AL2023 ARM instances. | `string` | `"ami-09b9ca376adb3607c"` | no |
| <a name="input_eks_image_x86_64"></a> [eks\_image\_x86\_64](#input\_eks\_image\_x86\_64) | Recommended Amazon Linux AMI ID for AL2023 x86 based instances. | `string` | `"ami-0239e3e7b036949c1"` | no |
| <a name="input_eks_managed_node_groups"></a> [eks\_managed\_node\_groups](#input\_eks\_managed\_node\_groups) | EKS manages nodegroups | `any` | `{}` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Infrastructure environment name (e.g. development, staging, production). | `string` | `"development"` | no |
| <a name="input_external_dns_domain_filters"></a> [external\_dns\_domain\_filters](#input\_external\_dns\_domain\_filters) | Limit possible target zones by domain suffixes. | `string` | `"['example.org']"` | no |
| <a name="input_gitops_addons_org"></a> [gitops\_addons\_org](#input\_gitops\_addons\_org) | Git repository org/user contains for addons | `string` | `"https://github.com/valiton"` | no |
| <a name="input_gitops_addons_repo"></a> [gitops\_addons\_repo](#input\_gitops\_addons\_repo) | Git repository contains for addons | `string` | `"k8s-terraform-blueprints"` | no |
| <a name="input_gitops_addons_revision"></a> [gitops\_addons\_revision](#input\_gitops\_addons\_revision) | Git repository revision/branch/ref for addons | `string` | `"main"` | no |
| <a name="input_gitops_oss_addon_config_path"></a> [gitops\_oss\_addon\_config\_path](#input\_gitops\_oss\_addon\_config\_path) | Git repository path for oss specific addon configurations | `string` | `"argocd/addons/config/oss"` | no |
| <a name="input_gitops_oss_addons_basepath"></a> [gitops\_oss\_addons\_basepath](#input\_gitops\_oss\_addons\_basepath) | Git repository base path for oss specific addons | `string` | `"argocd/addons/"` | no |
| <a name="input_gitops_oss_addons_path"></a> [gitops\_oss\_addons\_path](#input\_gitops\_oss\_addons\_path) | Git repository path for oss specific addons | `string` | `"oss"` | no |
| <a name="input_gitops_oss_workload_basepath"></a> [gitops\_oss\_workload\_basepath](#input\_gitops\_oss\_workload\_basepath) | Git repository base path for oss specific addon resources | `string` | `"addon-dependent-resources/"` | no |
| <a name="input_gitops_oss_workload_path"></a> [gitops\_oss\_workload\_path](#input\_gitops\_oss\_workload\_path) | Git repository path for oss specific addon resources | `string` | `"oss"` | no |
| <a name="input_gitops_vendor_addon_config_path"></a> [gitops\_vendor\_addon\_config\_path](#input\_gitops\_vendor\_addon\_config\_path) | Git repository path for vendor specific addon configurations | `string` | `"argocd/addons/config/vendors/aws"` | no |
| <a name="input_gitops_vendor_addons_basepath"></a> [gitops\_vendor\_addons\_basepath](#input\_gitops\_vendor\_addons\_basepath) | Git repository base path for vendor specific addons | `string` | `"argocd/addons/vendors/"` | no |
| <a name="input_gitops_vendor_addons_path"></a> [gitops\_vendor\_addons\_path](#input\_gitops\_vendor\_addons\_path) | Git repository path for vendor specific addons | `string` | `"aws"` | no |
| <a name="input_gitops_vendor_workload_basepath"></a> [gitops\_vendor\_workload\_basepath](#input\_gitops\_vendor\_workload\_basepath) | Git repository base path for vendor specific addon resources | `string` | `"addon-dependent-resources/vendors/"` | no |
| <a name="input_gitops_vendor_workload_path"></a> [gitops\_vendor\_workload\_path](#input\_gitops\_vendor\_workload\_path) | Git repository path for vendor specific addon resources | `string` | `"aws"` | no |
| <a name="input_gitops_workload_org"></a> [gitops\_workload\_org](#input\_gitops\_workload\_org) | Git repository org/user contains for workload | `string` | `"https://github.com/valiton"` | no |
| <a name="input_gitops_workload_repo"></a> [gitops\_workload\_repo](#input\_gitops\_workload\_repo) | Git repository contains for workload | `string` | `"k8s-terraform-blueprints"` | no |
| <a name="input_gitops_workload_revision"></a> [gitops\_workload\_revision](#input\_gitops\_workload\_revision) | Git repository revision/branch/ref for workload | `string` | `"main"` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Kubernetes version | `string` | `"1.32"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"eu-central-1"` | no |
| <a name="input_route53_zone"></a> [route53\_zone](#input\_route53\_zone) | Limit possible route53 zones. | `string` | `"*"` | no |
| <a name="input_single_nat_gateway"></a> [single\_nat\_gateway](#input\_single\_nat\_gateway) | True if only a single NAT gateway should be deployed instead of one per AZ | `bool` | `false` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | VPC CIDR, if empty a random CIDR will be chosen | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_argocd"></a> [access\_argocd](#output\_access\_argocd) | ArgoCD Access |
| <a name="output_configure_argocd"></a> [configure\_argocd](#output\_configure\_argocd) | Terminal Setup |
| <a name="output_configure_kubectl"></a> [configure\_kubectl](#output\_configure\_kubectl) | Configure kubectl: make sure you're logged in with the correct AWS profile and run the following command to update your kubeconfig |

## Best Practices
- Use **remote state storage** (e.g., S3 + DynamoDB) to manage state files.
- Follow the **principle of least privilege** when defining IAM roles.
- Enable **logging and monitoring** with AWS CloudWatch and GuardDuty.

## Contributing
Feel free to submit **issues and pull requests** to improve this module.

## License
This module is licensed under the **MIT License**. See the [License](../../../License) file for details.
