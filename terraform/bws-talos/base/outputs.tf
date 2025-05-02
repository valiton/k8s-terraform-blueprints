output "talosconfig" {
  description = "Talosconfig of the new cluster"
  value       = data.talos_client_configuration.talos.talos_config
  sensitive   = true
}

output "controlplane_nodes" {
  description = "Internal IPs of controlplanes, needed for talosctl --nodes parameter"
  value       = module.network.controlplane_fixed_ips
}

output "worker_machine_configuration" {
  description = "Machine Configuration for worker nodes"
  value       = module.talos-config.worker_machine_configuration
}

output "controlplane_machine_configuration" {
  description = "Machine Configuration for controlplan nodes"
  value       = module.talos-config.controlplane_machine_configuration
}

output "x_download_kubeconfig" {
  description = "Terminal Setup"
  value       = <<-EOT
    terraform output -raw talosconfig > talosconfig
    talosctl --talosconfig ./talosconfig --nodes ${module.network.controlplane_fixed_ips[0]} kubeconfig
    EOT
}

output "x_configure_argocd" {
  description = "Terminal Setup"
  value       = <<-EOT
    export ARGOCD_OPTS="--port-forward --port-forward-namespace argocd --grpc-web"
    kubectl config set-context --current --namespace argocd
    argocd login --port-forward --username admin --password $(argocd admin initial-password | head -1)
    echo "ArgoCD Username: admin"
    echo "ArgoCD Password: $(kubectl get secrets argocd-initial-admin-secret -n argocd --template="{{index .data.password | base64decode}}")"
    echo Port Forward: http://localhost:8080
    kubectl port-forward -n argocd svc/argo-cd-argocd-server 8080:80
    EOT
}

output "x_access_argocd" {
  description = "ArgoCD Access"
  value       = <<-EOT
    echo "ArgoCD Username: admin"
    echo "ArgoCD Password: $(kubectl get secrets argocd-initial-admin-secret -n argocd --template="{{index .data.password | base64decode}}")"
    echo "ArgoCD URL: https://$(kubectl get svc -n argocd argo-cd-argocd-server -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
    EOT
}

output "test_addons_include" {
  value = "{${join(",", [for key, value in var.addons : "addon_${regex("enable_(.+)", key)[0]}_appset.yaml" if value])}}"
}
