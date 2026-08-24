#
# Resource Group
#
resource "azurerm_resource_group" "rg_todo_kv" {
  name     = "rg-${var.project_name}-kv-${var.env}"
  location = var.location
}

#
# Key Vault
#
module "key_vault" {
  source = "git::https://github.com/CorporalCiprian/terraform-modules//modules/kv"
  location = azurerm_resource_group.rg_todo_kv.location
  rgname = azurerm_resource_group.rg_todo_kv.name
  sku = "standard"
}


#
# Secrets
#
resource "azurerm_key_vault_secret" "connection_string_db" {
  name         = "${var.project_name}-connection-string-${var.env}"
  value        = "postgresql://${module.db_module.administrator_login}:${azurerm_key_vault_secret.db_pass.value}@${module.db_module.fqdn}:5432/${module.db_module.dbname}?sslmode=require"
  key_vault_id = module.key_vault.id

  lifecycle {
    ignore_changes = [value]
  }
}

resource "azurerm_key_vault_secret" "db_pass" {
  name         = "${var.project_name}-db-pass-${var.env}"
  value        = "1q2w3e"
  key_vault_id = module.key_vault.id

  lifecycle {
    ignore_changes = [value]
  }
}

# locals {
#   kv_access_type = {
#     "user" = "bb0514bf-e920-4ad4-855a-1e7be403d253"
#     "sp_github" = "896d863f-7800-4972-9ef0-d7b63e09dbcf"
#   }
# }

# resource "azurerm_key_vault_access_policy" "kv_ap" {
#   key_vault_id = azurerm_key_vault.kv_todo.id
#   tenant_id    = data.azurerm_client_config.current.tenant_id

#   for_each        = local.kv_access_type
#   object_id       = each.value
#   key_permissions = var.key_permissions

#   secret_permissions = var.secret_permissions
# }

# resource "azurerm_key_vault_access_policy" "kv-ap-func" {
#   key_vault_id = azurerm_key_vault.kv_todo.id
#   tenant_id    = data.azurerm_client_config.current.tenant_id

#   object_id       = azurerm_linux_function_app.func_todo_backend.identity[0].principal_id
#   key_permissions = var.key_permissions

#   secret_permissions = var.secret_permissions
# }
