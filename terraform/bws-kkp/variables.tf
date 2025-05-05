variable "kkp_api_base_url" {}
variable "kkp_token" {}
variable "project_id" {}
variable "cluster_name" {}
variable "datacenter" {}
variable "kubernetes_version" {}

variable "os_app_cred_id" {
  sensitive = true
}
variable "os_app_cred_secret" {
  sensitive = true
}
variable "os_project" {}
variable "os_domain" {}

variable "os_image_name" {}
variable "os_instance_flavor" {}

variable "replicas" {
  default = 2
}
