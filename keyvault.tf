resource "azurerm_key_vault" "kv_todo" {
  name                       = "kv-todo-db"
  location                   = azurerm_resource_group.rg_todo.location
  resource_group_name        = azurerm_resource_group.rg_todo.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = var.sku_name
  soft_delete_retention_days = 7
}

/*resource "azurerm_key_vault_secret" "secret_db" {
  name         = "connection-string"
  value        = var.connection_string_value
  key_vault_id = azurerm_key_vault.kv_todo.id

  lifecycle {
    ignore_changes = [value]
  }

  depends_on = [azurerm_key_vault_access_policy.kv_ap]
}*/