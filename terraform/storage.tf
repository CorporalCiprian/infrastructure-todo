#
# Resource Group
#
resource "azurerm_resource_group" "rg_todo_stg" {
  name     = "rg-${var.project_name}-stg-${var.env}"
  location = var.location
}

#
# Storage account
#
module "stg_func_app" {
  source         = "git::https://github.com/CorporalCiprian/terraform-modules//modules/stg"
  rgname         = azurerm_resource_group.rg_todo_stg.name
  location       = azurerm_resource_group.rg_todo_stg.location
  network_access = false
  project_name   = "td"
}