resource "azurerm_key_vault" "kv_todo" {
  name                       = var.kv_name
  location                   = azurerm_resource_group.rg_todo.location
  resource_group_name        = azurerm_resource_group.rg_todo.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = var.sku_name
  soft_delete_retention_days = 7
  rbac_authorization_enabled = true
  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_key_vault_secret" "connection_string_db" {
  name         = var.connection_string_name
  value        = "postgresql://${azurerm_postgresql_flexible_server.db_server.administrator_login}:${var.db_password}@${azurerm_postgresql_flexible_server.db_server.fqdn}:5432/${azurerm_postgresql_flexible_server_database.todo_db.name}"
  key_vault_id = azurerm_key_vault.kv_todo.id

  lifecycle {
    ignore_changes = [ value ]
  }
}

resource "azurerm_key_vault_secret" "db_pass" {
  name = var.db_pass_name
  value = var.db_password
  key_vault_id = azurerm_key_vault.kv_todo.id

  lifecycle {
    ignore_changes = [ value ]
  }
}