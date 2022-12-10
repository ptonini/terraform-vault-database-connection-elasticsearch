resource "random_string" "this" {
  length  = 8
  special = false
}

resource "random_password" "this" {
  length  = 16
  special = false
}

resource "elasticsearch_xpack_role" "this" {
  provider  = elasticsearch
  role_name = "${var.role_name_prefix}-${random_string.this.result}"
  cluster   = ["manage_security"]
}

resource "elasticsearch_xpack_user" "this" {
  provider = elasticsearch
  username = "${var.role_name_prefix}-${random_string.this.result}"
  password = random_password.this.result
  roles = [
    elasticsearch_xpack_role.this.role_name
  ]
}

resource "vault_database_secret_backend_connection" "this" {
  name        = var.name
  plugin_name = "elasticsearch-database-plugin"
  backend     = try(var.backend.path, var.backend)
  elasticsearch {
    url      = var.elasticsearch_url
    username = elasticsearch_xpack_user.this.username
    password = random_password.this.result
  }
  allowed_roles     = var.allowed_roles
  verify_connection = var.verify_connection
}

resource "vault_generic_endpoint" "rotate_root" {
  path                 = "${vault_database_secret_backend_connection.this.backend}/rotate-root/${vault_database_secret_backend_connection.this.name}"
  ignore_absent_fields = true
  disable_read         = true
  disable_delete       = true
  data_json            = "{}"
  depends_on = [
    vault_database_secret_backend_connection.this
  ]
}