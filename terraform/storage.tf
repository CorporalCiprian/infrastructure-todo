#
# Resource Group
#
resource "azurerm_resource_group" "rg_todo_stg" {
  name = "rg-${var.project_name}-stg-${var.env}"
  location = var.location
}

module "stg_func_app" {
  source = "git::https://github.com/CorporalCiprian/terraform-modules//modules/stg"
  rgname = azurerm_resource_group.rg_todo_stg.name
  location = azurerm_resource_group.rg_todo_stg.location
  network_access = false
}

# resource "azurerm_storage_account" "stg_func_app_fr" {
#   name = "stg${var.project_name}frontend${var.env}"
#   resource_group_name = azurerm_resource_group.rg_todo_stg.name
#   location = azurerm_resource_group.rg_todo_stg.location
#   account_tier    = "Standard"
#   account_replication_type  = "LRS"
# }