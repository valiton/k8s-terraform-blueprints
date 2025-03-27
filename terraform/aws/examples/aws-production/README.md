# AWS EKS Blueprint for Production Environment

## Usage

This example shows you a simple production deployment with a multi-AZ setup for an EKS cluster. You can provision it using the following commands: 

```bash
terraform init
terraform plan
terraform apply --auto-approve
```

Once the terraform has been executed and the EKS cluster is being created, you can access the EKS cluster using the following commands: 

```bash
aws eks update-kubeconfig --name eks-production-example
```
