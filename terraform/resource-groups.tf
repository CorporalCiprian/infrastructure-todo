resource "azurerm_resource_group" "rg_todo" {
  location = var.location
  name     = var.resource_group_name
}