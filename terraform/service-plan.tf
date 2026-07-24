resource "azurerm_service_plan" "asp_func_apps" {
  name    = "asp-todo-backend"
  resource_group_name = azurerm_resource_group.rg_todo.name
  location = azurerm_resource_group.rg_todo.location
  sku_name = "S1"
  os_type   = "Linux"
}
