output "worker_machine_configuration" {
  description = "Talos configuration for worker nodes"
  value       = data.talos_machine_configuration.worker.machine_configuration
  sensitive   = true
}

output "controlplane_machine_configuration" {
  description = "Talos configuration for controlplane nodes"
  value       = data.talos_machine_configuration.controlplane.machine_configuration
  sensitive   = true
}

output "talos_client_configuration" {
  description = "Talos client configuration"
  value       = data.talos_client_configuration.talos
  sensitive   = true
}
