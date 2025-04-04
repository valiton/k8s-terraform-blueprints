variable "os_application_credential_id" {}

variable "os_application_credential_secret" {}

variable "os_auth_url" {
  default = "https://dashboard.bws.burda.com:5000"
}

variable "kube_api_external_ip" {}

variable "kube_api_external_port" {
  default = 6443
}

variable "talos_secrets_file" {
  default = "secrets.yaml"
}
