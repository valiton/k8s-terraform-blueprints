provider "restapi" {
  uri = "${var.kkp_api_url}/api/v2/projects/${var.project_id}/clusters"
  headers = {
    Authorization = "Bearer ${var.kkp_token}"
    Content-Type  = "application/json"
  }
  write_returns_object = true
}

resource "restapi_object" "openstack_cluster" {
  path = "/"
  data = jsonencode({
    name   = var.cluster_name
    type   = "kubernetes"
    cloud  = {
      datacenterName = var.datacenter
      openstack = {
        username       = var.os_username
        password       = var.os_password
        project        = var.os_project
        projectID      = var.os_project_id
        domain         = var.os_domain
        floatingIpPool = var.os_floating_ip_pool
        network        = var.os_network_id
        securityGroups = var.os_security_groups
        routerID       = var.os_router_id
        subnetID       = var.os_subnet_id
      }
    }
    version = var.kubernetes_version
  })

  provisioner "local-exec" {
    when    = destroy
    command = "bash ./delete_openstack_cluster.sh ${var.kkp_api_url} ${var.project_id} ${self.response_body["id"]} ${var.kkp_token}"
  }
}

