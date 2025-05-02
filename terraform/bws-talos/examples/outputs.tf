output "talosconfig" {
  description = "Talos client configuration"
  value       = module.bws-talos.talosconfig
  sensitive   = true
}

output "worker_machine_configuration" {
  description = "Machine Configuration for worker nodes"
  value       = module.bws-talos.worker_machine_configuration
  sensitive   = true
}

output "controlplane_machine_configuration" {
  description = "Machine Configuration for controlplan nodes"
  value       = module.bws-talos.controlplane_machine_configuration
  sensitive   = true
}

output "x_download_kubeconfig" {
  description = "Terminal Setup"
  value       = <<-EOT
    tofu output -raw talosconfig > talosconfig
    talosctl --talosconfig ./talosconfig --nodes ${module.bws-talos.controlplane_nodes[0]} kubeconfig
    EOT
}
