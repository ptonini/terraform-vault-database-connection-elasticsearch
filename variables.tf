variable "name" {}

variable "backend" {}

variable "elasticsearch_url" {}

variable "allowed_roles" {
  type = list(string)
  default = ["*"]
}

variable "role_name_prefix" {
  default = "vault"
}

variable "vault_token" {}

variable "verify_connection" {
  default = true
}
