terraform {
  required_providers {
    restapi = {
      source  = "Mastercard/restapi"
      version = "~> 2.0.1"
    }
  }
}

provider "restapi" {
  uri = var.kkp_api_base_url
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
  provisioner "local-exec" {
    command = "./http_api_request_with_wait_loop.sh"
    interpreter = ["bash", "-c"]
    ## CAUTION: environment variables will retain values from previous runs, so we need to pass all of them!
    environment = {
      API_URL = "${var.kkp_api_base_url}/api/v2/projects/${var.project_id}/clusters/${restapi_object.openstack_cluster.id}/health"
      API_TOKEN = var.kkp_token
      API_HTTP_METHOD = "GET"
      API_ADDITIONAL_HEADERS = ""
      MATCH_HTTP_STATUS_CODE = 200
      MATCH_RESPONSE_JSON_FIELD_SELECTOR = ".machineController"
      MATCH_RESPONSE_JSON_FIELD_VALUE = "HealthStatusUp"
      TOTAL_WAIT_TIMEOUT_SECONDS = 300
      DEBUG = 1
    }
  }

  depends_on = [restapi_object.openstack_cluster]
}

resource "restapi_object" "machine_deployment" {
  provider = restapi

  path = "/api/v2/projects/${var.project_id}/clusters/${restapi_object.openstack_cluster.id}/machinedeployments"
  data = jsonencode({
    name       = "openstack-md"
    spec = {
      replicas   = var.replicas
        template = {
          cloud      = {
            openstack = {
              flavor    = var.os_instance_flavor
              image     = var.os_image_name
              diskSize  = 40
              availabilityZone = "az1"
            }
          }
          operatingSystem        = {
            ubuntu = {
              distUpgradeOnBoot = false
            }
          }
          versions = {
            kubelet = var.kubernetes_version
        }
      }
    }
  })

  depends_on = [null_resource.wait_for_cluster_ready]
}

resource "null_resource" "wait_for_machines_ready" {
  provisioner "local-exec" {
    command = "./http_api_request_with_wait_loop.sh"
    interpreter = ["bash", "-c"]
    ## CAUTION: environment variables will retain values from previous runs, so we need to pass all of them!
    environment = {
      API_URL = "${var.kkp_api_base_url}/api/v2/projects/${var.project_id}/clusters/${restapi_object.openstack_cluster.id}/machinedeployments"
      API_TOKEN = var.kkp_token
      API_HTTP_METHOD = "GET"
      API_ADDITIONAL_HEADERS = ""
      MATCH_HTTP_STATUS_CODE = 200
      MATCH_RESPONSE_JSON_FIELD_SELECTOR = ".[0].status.readyReplicas"
      MATCH_RESPONSE_JSON_FIELD_VALUE = var.replicas
      TOTAL_WAIT_TIMEOUT_SECONDS = 900
      DEBUG = 1
    }
  }

  depends_on = [restapi_object.machine_deployment]
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
    kkp_api_base_url = var.kkp_api_base_url
    project_id       = var.project_id
    kkp_token        = var.kkp_token
    cluster_id       = restapi_object.openstack_cluster.id
  }

  provisioner "local-exec" {
    when    = destroy

    command = "./http_api_request_with_wait_loop.sh"
    interpreter = ["bash", "-c"]
    ## CAUTION: environment variables will retain values from previous runs, so we need to pass all of them!
    environment = {
      API_URL = "${self.triggers.kkp_api_base_url}/api/v2/projects/${self.triggers.project_id}/clusters/${self.triggers.cluster_id}"
      API_TOKEN = self.triggers.kkp_token
      API_HTTP_METHOD = "DELETE"
      API_ADDITIONAL_HEADERS = "DeleteVolumes: true\nDeleteLoadBalancers: true"
      MATCH_HTTP_STATUS_CODE = 200
      MATCH_RESPONSE_JSON_FIELD_SELECTOR = ""
      MATCH_RESPONSE_JSON_FIELD_VALUE = ""
      TOTAL_WAIT_TIMEOUT_SECONDS = 1
      DEBUG = 1
    }
  }

  depends_on = [restapi_object.openstack_cluster]
}
