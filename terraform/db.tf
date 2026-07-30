resource "azurerm_postgresql_flexible_server" "db_server" {
  name                   = var.pg_server_name
  resource_group_name    = azurerm_resource_group.rg_todo.name
  location               = azurerm_resource_group.rg_todo.location
  administrator_login    = var.admin_db_login
  administrator_password = azurerm_key_vault_secret.db_pass.value
  sku_name = "B_Standard_B1ms"
  version = "16"

  lifecycle {
    ignore_changes = [ zone ]
  }
}

resource "azurerm_postgresql_flexible_server_database" "todo_db" {
  name      = var.pg_db_name
  server_id = azurerm_postgresql_flexible_server.db_server.id
}