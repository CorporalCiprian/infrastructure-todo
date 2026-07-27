resource "azurerm_key_vault" "kv_todo" {
  name                       = "kv-todo-db"
  location                   = azurerm_resource_group.rg_todo.location
  resource_group_name        = azurerm_resource_group.rg_todo.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = var.sku_name
  soft_delete_retention_days = 7

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_key_vault_secret" "connection_string_db" {
  name         = "connection-string"
  value        = "postgresql://${azurerm_postgresql_flexible_server.db_server.administrator_login}:${var.db_password}@${azurerm_postgresql_flexible_server.db_server.fqdn}:5432/${azurerm_postgresql_flexible_server_database.todo_db.name}"
  key_vault_id = azurerm_key_vault.kv_todo.id

  lifecycle {
    ignore_changes = [ value ]
  }

  depends_on = [azurerm_key_vault_access_policy.kv_ap]
}

resource "azurerm_key_vault_secret" "db_pass" {
  name = "db-password"
  value = var.db_password
  key_vault_id = azurerm_key_vault.kv_todo.id

  lifecycle {
    ignore_changes = [ value ]
  }
  
  depends_on = [ azurerm_key_vault_access_policy.kv_ap ]
}