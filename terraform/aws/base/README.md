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

## Inputs

### Base variables

The following variables enable you to configure the base setup that affects all components including the VPC and the cluster. 

| Variable                 | Type          | Description                                  | Default           |
|--------------------------|---------------|----------------------------------------------|-------------------|
| `environment`            | `string`      | Deployment environment (e.g., development)   | `"development"`   |
| `base_name`              | `string`      | Name of your base infrastructure             | `"my-project"`    |
| `vpc_cidr`               | `string`      | CIDR block for the VPC                       | `""`              |
| `azs_count`              | `number`      | Number of Availability Zones to use          | `2`               |
| `single_nat_gateway`     | `bool`        | Use a single NAT Gateway for all private subnets | `false`        |
| `region`                 | `string`      | AWS region for resource deployment           | `"eu-central-1"`  |

### EKS Cluster variables

The following variables are specific to the EKS cluster: 

| Variable                 | Type          | Description                                  | Default           |
|--------------------------|---------------|----------------------------------------------|-------------------|
| `base_node_group`            | `any`      | Base node groups that is used for our addon components (e.g. monitoring, scaling etc.)                   | `base_eks_node = {}`          |
| `eks_managed_node_groups`            | `string`      | Additional fixed EKS manages nodegroups (not recommended, use Karpenter)                  | `{}`          |
| `kubernetes_version`            | `string`      | Kubernetes version for EKS                   | `"1.32"`          |
| `addons`            | `string`      |Kubernetes addons that are deployed automatically, supported options are here: `enable_aws_ebs_csi_resources`, `enable_metrics_server`, `enable_aws_efs_csi_driver`, `enable_aws_load_balancer_controller`, `enable_external_secrets`, `enable_external_dns`, `enable_karpenter`. By default all plugins are deployed. | <code> { <br>&emsp; enable_aws_ebs_csi_resources = true<br> &emsp; enable_metrics_server               = true<br> &emsp; enable_aws_efs_csi_driver           = true<br> &emsp; enable_aws_load_balancer_controller = true<br> &emsp; enable_external_secrets             = true<br> &emsp; enable_external_dns                 = true<br> &emsp; enable_karpenter                    = true<br>}</code> |


### Karpenter Scaling Variables

In case Karpenter is being added in the EKS addons, we automatically deploy a base node pool that enables you autoscaling out of the box. The following variables can be used to configure Karpenter: 

| Variable                 | Type          | Description                                  | Default           |
|--------------------------|---------------|----------------------------------------------|-------------------|
| `base_nodepool`            | `string`      | Name of the base node pool that is being deployed by Karpenter. This is the node pool on which your applications can run.                    | `"base"`          |
| `base_nodepool_label`            | `string`      | The base node pool adds node labels on the provisioned nodes. By default, this is `base_node_pool`, use nodeSelector if you don't want to have your applications being run on these nodes. | `"base_node_pool"`          |


### GitOps Variables

We deploy by default ArgoCD and the following variables allow to configure GitOps (e.g. from which repository the base infrastructure should be fetched etc.). 

| Variable                 | Type          | Description                                  | Default           |
|--------------------------|---------------|----------------------------------------------|-------------------|
| `gitops_addons_org`            | `string`      | Git repository org/user contains for addons  | `"https://github.com/valiton"`          |
| `gitops_addons_repo`            | `string`      | Git repository contains for addons | `"k8s-terraform-blueprints"`          |
| `gitops_addons_revision`            | `string`      | Git repository revision/branch/ref for addons | `"main"`          |
| `gitops_addons_basepath`            | `string`      | Git repository base path for addon | `"argocd/cluster-addons/"`          |
| `gitops_addons_path`            | `string`      | Git repository path for addons | `"addons"`          |
| `gitops_workload_org`            | `string`      | Git repository org/user contains for workload | `"https://github.com/valiton"`          |
| `gitops_workload_repo`            | `string`      | Git repository contains for workload | `"k8s-terraform-blueprints"`          |
| `gitops_workload_revision`            | `string`      | Git repository revision/branch/ref for workload | `"main"`          |
| `gitops_workload_basepath`            | `string`      | Git repository base path for workload | `"addon-dependent-workload/"`          |
| `gitops_workload_path`            | `string`      | Git repository path for workload | `"addons"`          |

## Requirements
- Terraform **>= 1.0**
- AWS Provider **>= 4.0**

## Best Practices
- Use **remote state storage** (e.g., S3 + DynamoDB) to manage state files.
- Follow the **principle of least privilege** when defining IAM roles.
- Enable **logging and monitoring** with AWS CloudWatch and GuardDuty.

## Contributing
Feel free to submit **issues and pull requests** to improve this module.

## License
This module is licensed under the **MIT License**. See the [LICENSE](../LICENSE) file for details.
