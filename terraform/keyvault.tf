#
# Resource Group
#
resource "azurerm_resource_group" "rg_todo_kv" {
  name = "rg-${var.project_name}-kv-${var.env}"
  location = var.location
}

#
# Key Vault
#
resource "azurerm_key_vault" "kv_todo" {
  name                       = "kv-${var.project_name}-${var.env}v"
  location                   = azurerm_resource_group.rg_todo_kv.location
  resource_group_name        = azurerm_resource_group.rg_todo_kv.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  rbac_authorization_enabled = true
  public_network_access_enabled = false
  
  network_acls {
    default_action = "Deny"
    bypass = "AzureServices"
    
    virtual_network_subnet_ids = [azurerm_subnet.snet_backend.id]
    ip_rules = [
      "136.255.102.82/32",
    ]
  }
}


#
# Secrets
#
resource "azurerm_key_vault_secret" "connection_string_db" {
  name         = "${var.project_name}-connection-string-${var.env}"
  value        = "postgresql://${azurerm_postgresql_flexible_server.db_server.administrator_login}:${azurerm_key_vault_secret.db_pass.value}@${azurerm_postgresql_flexible_server.db_server.fqdn}:5432/${azurerm_postgresql_flexible_server_database.todo_db.name}?sslmode=require"
  key_vault_id = azurerm_key_vault.kv_todo.id

  lifecycle {
    ignore_changes = [ value ]
  }
}

resource "azurerm_key_vault_secret" "db_pass" {
  name = "${var.project_name}-db-pass-${var.env}"
  value = "1q2w3e"
  key_vault_id = azurerm_key_vault.kv_todo.id

  lifecycle {
    ignore_changes = [ value ]
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