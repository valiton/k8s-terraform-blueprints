terraform {
  required_providers {
    restapi = {
      source  = "Mastercard/restapi"
      version = "~> 2.0.1"
    }
  }
}

provider "restapi" {
  uri = "${var.kkp_api_url}"
  headers = {
    Authorization = "Bearer ${var.kkp_token}"
    Content-Type  = "application/json"
  }
  write_returns_object = true
  debug                = true
}

resource "restapi_object" "openstack_cluster" {
  path           = "/api/v2/projects/${var.project_id}/clusters"
  create_method  = "POST"
  read_method    = "GET"
  update_method  = "PATCH"
  destroy_method = "DELETE"
  id_attribute   = "id"
  data = jsonencode({
    cluster = {
      name   = var.cluster_name
      type   = "kubernetes"
      spec = {
        cloud  = {
          dc = var.datacenter
          openstack = {
            applicationCredentialID     = var.os_app_cred_id
            applicationCredentialSecret = var.os_app_cred_secret
            domain                      = var.os_domain
            #project                     = var.os_project
            image                       = var.os_image_name
            flavor                      = var.os_instance_flavor
          }
        }
        version = var.kubernetes_version
        enforceAuditLogging      = true
      }
    }
  })

}



# Wait for cluster to be up before creating machine deployment
resource "null_resource" "wait_for_cluster_ready" {
  depends_on = [restapi_object.openstack_cluster]

  provisioner "local-exec" {
    command = "sleep 60"
  }
}

resource "restapi_object" "machine_deployment" {
  provider = restapi

  path = "/api/v2/projects/${var.project_id}/clusters/${restapi_object.openstack_cluster.id}/machinedeployments"
  data = jsonencode({
    name       = "openstack-md"
    spec = {
      replicas   = 2
        template = {
          cloud      = {
            openstack = {
              flavor    = var.os_instance_flavor
              image     = var.os_image_name
              diskSize  = 40
            }
          }
          operatingSystem        = {
            ubuntu = {}
          }
          operatingSystemProfile = "osp-ubuntu"
      }
    }
  })

  depends_on = [null_resource.wait_for_cluster_ready]
}

resource "null_resource" "save_cluster_id" {
  provisioner "local-exec" {
    command = <<EOT
      echo "${restapi_object.openstack_cluster.id}" > .cluster_id
    EOT
  }

  depends_on = [restapi_object.openstack_cluster]
}

resource "null_resource" "delete_cluster" {
  triggers = {
    kkp_api_url      = var.kkp_api_url
    project_id       = var.project_id
    kkp_token        = var.kkp_token
  }

  provisioner "local-exec" {
    when    = destroy
    command = "bash ./delete_openstack_cluster.sh ${self.triggers.kkp_api_url} ${self.triggers.project_id} ${self.triggers.kkp_token}"
  }

  depends_on = [null_resource.save_cluster_id]
}
