resource "azurerm_storage_account" "stg_func_app" {
  name = "sttodobackend"
  resource_group_name = azurerm_resource_group.rg_todo.name
  location = azurerm_resource_group.rg_todo.location
  account_tier    = "Standard"
  account_replication_type  = "LRS"
}