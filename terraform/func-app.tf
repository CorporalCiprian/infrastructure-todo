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

  app_settings = {
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
    "ENABLE_ORYX_BUILD"              = "true"

    "AzureWebJobsFeatureFlags" = "EnableWorkerIndexing"
    "FUNCTIONS_WORKER_RUNTIME"  = "python"

    //"DATABASE_URL" = "postgresql://${azurerm_postgresql_flexible_server.db.administrator_login}:${var.db_password}@${azurerm_postgresql_flexible_server.db.fqdn}:5432/${azurerm_postgresql_flexible_server_database.todo_db.name}"
    
    //"ALLOWED_ORIGINS" = var.allowed_origins
  }
}
