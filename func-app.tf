resource "azurerm_linux_function_app" "func_todo_backend" {
  name  = "func-todo-backend"
  resource_group_name = azurerm_resource_group.rg_todo.name
  service_plan_id = azurerm_service_plan.asp_func_apps.id
  storage_account_name = azurerm_storage_account.stg_func_app.name
  location = azurerm_resource_group.rg_todo.location
  storage_account_access_key = azurerm_storage_account.stg_func_app.primary_access_key
  identity{
    type = "SystemAssigned"
  }
  site_config {
    application_stack {
        python_version = 3.12
    }
  }

}
