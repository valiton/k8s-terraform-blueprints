output "controlplane_instance" {
  description = "Controlplane instances"
  value       = openstack_compute_instance_v2.controlplane
}
