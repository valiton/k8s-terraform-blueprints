# Terraform Blueprints for Kubernetes Infrastructures

## Overview

This repository provides Terraform blueprints for setting up Kubernetes infrastructures efficiently. The goal is to standardize and simplify the provisioning of Kubernetes clusters, reducing setup time, maintenance effort, and ensuring consistency across projects.

## Motivation

Setting up Kubernetes infrastructures often involves repetitive tasks, similar tools, and high maintenance overhead. This project aims to:

- Provide a structured approach to setting up Kubernetes infrastructures.
- Reduce setup costs and complexity.
- Ensure a modular and maintainable architecture.

## Project Structure

The infrastructure is structured into three layers:

### **Layer 1: Cloud**

This layer handles the provisioning of cloud resources such as compute instances, networking, storage, and security configurations. The structure is cloud-agnostic, making it possible to support multiple cloud providers in the future.

- Currently supports **AWS EKS**.
- Future support planned for **Google Cloud (GKE), Microsoft Azure (AKS), Hetzner, etc.**

### **Layer 2: Tooling**

This layer includes essential Kubernetes add-ons for cluster management:

- **Monitoring** (e.g. Prometheus, Grafana)
- **Scaling** (e.g. Karpenter)
- **Secret Handling** (e.g. External Secrets)
- **DNS Handling** (e.g. External DNS)

### **Layer 3: Application Layer**

This layer is designed for deploying applications and managing workloads:

- Supports Helm-based deployments.
- Enables CI/CD integrations for automated deployments.

## Features

- **Cloud-Agnostic**: Modular design to support multiple cloud providers.
- **Automated Provisioning**: Uses Terraform to automate infrastructure setup.
- **Best Practices**: Follows industry best practices for Kubernetes infrastructure.
- **Scalability & Maintainability**: Designed to grow with your workloads.

## Getting Started

### Prerequisites

- Terraform installed ([Download here](https://www.terraform.io/downloads.html)) or OpenTofu installed ([Download here](https://opentofu.org/docs/intro/install/]))
- AWS CLI configured ([Setup guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html))
- kubectl installed ([Installation guide](https://kubernetes.io/docs/tasks/tools/))

### Usage

The repository is structured to help you easily locate the cloud-specific Terraform configurations. Within the `terraform` folder, you'll find subdirectories corresponding to different cloud providers. Our goal is to maintain the following structure:

```
k8s-terraform-blueprints/
├── License
├── README.md
├── addon-dependent-resources
│   ├── oss
│   └── vendors
├── argocd
│   ├── README.md
│   └── addons
├── terraform
│   └── cloud-provider
│       └── aws```

The examples folder contains various example implementations. Below is a snippet from the **Base Module example**, which provisions a fully functional VPC and EKS cluster following our best practices:

```hcl
provider "aws" {
  region = "eu-central-1"
}

module "base" {
  source = "git::git@github.com:valiton/k8s-terraform-blueprints.git//terraform/aws/base?ref=main"
 
  base_name = "my_project"
}
```

For more details, check out the general [AWS base module documentation](./terraform/cloud-provideraws/base/) and the [example folder](./terraform/cloud-provider/aws/examples/).

## Contributing

We welcome contributions! Feel free to open issues and pull requests to improve the project.

## License

This project is licensed under the MIT License - see the [License](License) file for details.

## Contact

For any questions, feel free to reach out via GitHub issues or discussions.

