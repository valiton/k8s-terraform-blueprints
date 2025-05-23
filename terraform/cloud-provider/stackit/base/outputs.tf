output "cluster_egress_address_ranges" {
  description = "The outgoing network ranges (in CIDR notation) of traffic originating from workload on the cluster."
  value       = stackit_ske_cluster.managed_cluster.egress_address_ranges[0]
}

output "cluster_id" {
  description = "Terraform's internal resource ID. It is structured as `project_id`,`region`,`name`."
  value       = stackit_ske_cluster.managed_cluster.id
}

output "cluster_kubernetes_version_used" {
  description = "Full Kubernetes version used."
  value       = stackit_ske_cluster.managed_cluster.kubernetes_version_used
}


