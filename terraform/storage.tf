#
# Resource Group
#
resource "azurerm_resource_group" "rg_todo_stg" {
  name = "rg-${var.project_name}-stg-${var.env}"
  location = var.location
}

#
# Resource Lock
#
resource "azurerm_management_lock" "stg_lock" {
  name       = "stglock"
  scope      = azurerm_resource_group.rg_todo_stg.id
  lock_level = "CanNotDelete"
}

#
# Storage accounts
#
resource "azurerm_storage_account" "stg_func_app_bk" {
  name = "stg${var.project_name}backend${var.env}v"
  resource_group_name = azurerm_resource_group.rg_todo_stg.name
  location = azurerm_resource_group.rg_todo_stg.location
  account_tier    = "Standard"
  account_replication_type  = "LRS"
}

resource "azurerm_storage_account" "stg_func_app_fr" {
  name = "stg${var.project_name}frontend${var.env}"
  resource_group_name = azurerm_resource_group.rg_todo_stg.name
  location = azurerm_resource_group.rg_todo_stg.location
  account_tier    = "Standard"
  account_replication_type  = "LRS"
}