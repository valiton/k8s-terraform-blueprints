variable "cluster_name" {
  description = "Name of the cluster"
  default     = "my-cluster"
}

variable "cluster_endpoint" {
  description = "Endpoint of the cluster (IP or domain name)"
  default     = "my-cluster.example.com"
}

variable "kubernetes_version" {
  description = "Kubernetes version to install"
  default     = "v1.32.2"
}

variable "os_ccm_version" {
  description = "Openstack cloud controller manager version"
  default     = "v1.32.0"
}

variable "os_auth_url" {
  description = "Openstack Keystone url"
  default     = "https://dashboard.example.com:5000/"
}

variable "os_application_credential_id" {
  description = "Openstack application credentials ID"
  default     = ""
}

variable "os_application_credential_secret" {
  description = "Openstack application credentials secret"
  default     = ""
}

variable "public_network_id" {
  description = "ID of the public network"
  type        = string
  default     = "dfae-3345"
}

variable "private_network_subnet_id" {
  description = "ID of the private subnet"
  type        = string
  default     = "dfae-3345"
}

variable "custom_ca_cert" {
  description = "CA certificate that Kubernetes will additionally trust"
  default     = ""
}
