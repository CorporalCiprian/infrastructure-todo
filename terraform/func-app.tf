#
# Resource group
#
resource "azurerm_resource_group" "rg_todo_func_app" {
  name = "rg-${var.project_name}-app-${var.env}"
  location = var.location
}

#
# App Service plan
#
resource "azurerm_service_plan" "asp_func_apps" {
  name    = "asp-${var.project_name}-${var.env}"
  resource_group_name = azurerm_resource_group.rg_todo_func_app.name
  location = azurerm_resource_group.rg_todo_func_app.location
  sku_name = "S1"
  os_type   = "Linux"
}

#
# Func App
#
resource "azurerm_linux_function_app" "func_todo_backend" {
  name  = "func-app-${var.project_name}-backend-${var.env}"
  resource_group_name = azurerm_resource_group.rg_todo_func_app.name
  location = azurerm_resource_group.rg_todo_func_app.location

  service_plan_id = azurerm_service_plan.asp_func_apps.id
  
  storage_uses_managed_identity = true
  storage_account_name = azurerm_storage_account.stg_func_app_bk.name
  # TODO: func app connects to storage account with managed identity instead of sas key

  identity{
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
        python_version = "3.12"
    }
    always_on = true
  }

  app_settings = {
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "false"
    "ENABLE_ORYX_BUILD"              = "false"

    "WEBSITE_RUN_FROM_PACKAGE" = "1"
    "AzureWebJobsFeatureFlags" = "EnableWorkerIndexing"
    "FUNCTIONS_WORKER_RUNTIME"  = "python"

    "DATABASE_URL" = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.connection_string_db.versionless_id})"
    
    "ALLOWED_ORIGINS" = "https://${azurerm_linux_function_app.func_todo_frontend.name}.azurewebsites.net"
    "AzureWebJobsStorage__accountName" = azurerm_storage_account.stg_func_app_bk.name

    "env" = var.env
  }

  lifecycle {
    ignore_changes = [ app_settings["WEBSITE_RUN_FROM_PACKAGE"], app_settings["AzureWebJobsStorage__accountName"],]
  }
}

resource "azurerm_linux_function_app" "func_todo_frontend" {
  name = "func-app-${var.project_name}-frontend-${var.env}"
  resource_group_name = azurerm_resource_group.rg_todo_func_app.name
  service_plan_id = azurerm_service_plan.asp_func_apps.id
  location = azurerm_resource_group.rg_todo_func_app.location

  storage_uses_managed_identity = true
  storage_account_name = azurerm_storage_account.stg_func_app_fr.name
  
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
    
    "AzureWebJobsStorage__accountName" = azurerm_storage_account.stg_func_app_fr.name
  }

  lifecycle {
    ignore_changes = [ app_settings["WEBSITE_RUN_FROM_PACKAGE"], app_settings["AzureWebJobsStorage__accountName"],]
  }
}
