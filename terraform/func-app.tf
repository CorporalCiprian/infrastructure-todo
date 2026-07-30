resource "azurerm_linux_function_app" "func_todo_backend" {
  name  = var.backend_name
  resource_group_name = azurerm_resource_group.rg_todo.name
  service_plan_id = azurerm_service_plan.asp_func_apps.id
  storage_account_name = azurerm_storage_account.stg_func_app_bk.name
  location = azurerm_resource_group.rg_todo.location
  storage_account_access_key = azurerm_storage_account.stg_func_app_bk.primary_access_key
  identity{
    type = "SystemAssigned"
  }
  site_config {
    application_stack {
        python_version = "3.12"
    }
  }

  app_settings = {
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "false"
    "ENABLE_ORYX_BUILD"              = "false"

    "WEBSITE_RUN_FROM_PACKAGE" = "1"
    "AzureWebJobsFeatureFlags" = "EnableWorkerIndexing"
    "FUNCTIONS_WORKER_RUNTIME"  = "python"

    "DATABASE_URL" = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.connection_string_db.versionless_id})"
    
    "ALLOWED_ORIGINS" = var.allowed_origins
  }

  lifecycle {
    ignore_changes = [ app_settings["WEBSITE_RUN_FROM_PACKAGE"],]
  }
}

resource "azurerm_linux_function_app" "func_todo_frontend" {
  name = var.frontend_name
  resource_group_name = azurerm_resource_group.rg_todo.name
  service_plan_id = azurerm_service_plan.asp_func_apps.id
  storage_account_name = azurerm_storage_account.stg_func_app_fr.name
  location = azurerm_resource_group.rg_todo.location
  storage_account_access_key = azurerm_storage_account.stg_func_app_fr.primary_access_key
  identity {
    type = "SystemAssigned"
  }
  site_config {
    application_stack {
      node_version = "24"
    }
    always_on = true
  }

  app_settings = {
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "false"
    "ENABLE_ORYX_BUILD"              = "false"
    
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
    "AzureWebJobsFeatureFlags" = "EnableWorkerIndexing"
    "FUNCTIONS_WORKER_RUNTIME"  = "node"
    
  }

  lifecycle {
    ignore_changes = [ app_settings["WEBSITE_RUN_FROM_PACKAGE"],]
  }
}
