output "talosconfig" {
  value     = module.bws-talos.talosconfig
  sensitive = true
}

output "controlplane_nodes" {
  value = module.bws-talos.controlplane_nodes
}
