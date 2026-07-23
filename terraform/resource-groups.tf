resource "azurerm_resource_group" "rg_todo" {
  location = var.location
  name     = "rg-todo"
}