#
# Resource Group
#
resource "azurerm_resource_group" "rg_todo_db" {
  name = "rg-${var.project_name}-db-${var.env}"
  location = var.location
}

#
# Database server
#
resource "azurerm_postgresql_flexible_server" "db_server" {
  name                   = "${var.project_name}-pg-server-${var.env}"
  resource_group_name    = azurerm_resource_group.rg_todo_db.name
  location               = azurerm_resource_group.rg_todo_db.location
  administrator_login    = "postgres"
  administrator_password = azurerm_key_vault_secret.db_pass.value
  sku_name = "B_Standard_B1ms"
  version = "16"

  delegated_subnet_id = azurerm_subnet.snet_db.id

  public_network_access_enabled = false
  
  lifecycle {
    ignore_changes = [ zone ]
  }

  depends_on = [azurerm_private_dns_zone_virtual_network_link.db_dns_link]
}

#
# Postgresql Database
#
resource "azurerm_postgresql_flexible_server_database" "todo_db" {
  name      = "${var.project_name}-db-${var.env}"
  server_id = azurerm_postgresql_flexible_server.db_server.id
}