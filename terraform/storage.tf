resource "azurerm_storage_account" "stg_func_app_bk" {
  name = var.st_backend_name
  resource_group_name = azurerm_resource_group.rg_todo.name
  location = azurerm_resource_group.rg_todo.location
  account_tier    = "Standard"
  account_replication_type  = "LRS"

  lifecycle {
    prevent_destroy = true
  }
}

resource "azurerm_storage_account" "stg_func_app_fr" {
  name = var.st_frontend_name
  resource_group_name = azurerm_resource_group.rg_todo.name
  location = azurerm_resource_group.rg_todo.location
  account_tier    = "Standard"
  account_replication_type  = "LRS"

  lifecycle {
    prevent_destroy = true
  }
}