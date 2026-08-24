#
# Resource group
#
resource "azurerm_resource_group" "rg_todo_func_app" {
  name     = "rg-${var.project_name}-app-${var.env}"
  location = var.location
}

#
# App Service plan
#
resource "azurerm_service_plan" "asp_func_apps" {
  name                = "asp-${var.project_name}-${var.env}"
  resource_group_name = azurerm_resource_group.rg_todo_func_app.name
  location            = azurerm_resource_group.rg_todo_func_app.location
  sku_name            = "S2"
  os_type             = "Linux"
}

#
# Func Apps
#
resource "azurerm_linux_function_app" "func_todo_backend" {
  name                = "func-app-${var.project_name}-backend-${var.env}"
  resource_group_name = azurerm_resource_group.rg_todo_func_app.name
  location            = azurerm_resource_group.rg_todo_func_app.location

  service_plan_id = azurerm_service_plan.asp_func_apps.id

  storage_uses_managed_identity = true
  storage_account_name          = module.stg_func_app.name

  virtual_network_subnet_id = azurerm_subnet.snet_backend.id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      python_version = "3.12"
    }
    ip_restriction_default_action = "Deny"
    always_on              = true
    vnet_route_all_enabled = true
    ip_restriction {
      action = "Allow"
      ip_address = "136.255.102.82/32"
      priority = 100
    }
  }

  app_settings = {
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "false"
    "ENABLE_ORYX_BUILD"              = "false"

    "WEBSITE_VNET_ROUTE_ALL" = "1"
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
    "AzureWebJobsFeatureFlags" = "EnableWorkerIndexing"
    "FUNCTIONS_WORKER_RUNTIME" = "python"

    "DATABASE_URL" = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.connection_string_db.versionless_id})"

    "ALLOWED_ORIGINS"                  = "https://${azurerm_linux_function_app.func_todo_frontend.name}.azurewebsites.net"
    "AzureWebJobsStorage__accountName" = module.stg_func_app.name

    "env" = var.env
  }

  lifecycle {
    ignore_changes = [app_settings["WEBSITE_RUN_FROM_PACKAGE"], app_settings["AzureWebJobsStorage__accountName"], app_settings["WEBSITE_VNET_ROUTE_ALL"],]
  }


}

resource "azurerm_linux_function_app" "func_todo_frontend" {
  name                = "func-app-${var.project_name}-frontend-${var.env}"
  resource_group_name = azurerm_resource_group.rg_todo_func_app.name
  service_plan_id     = azurerm_service_plan.asp_func_apps.id
  location            = azurerm_resource_group.rg_todo_func_app.location

  storage_uses_managed_identity = true
  storage_account_name          = module.stg_func_app.name

  virtual_network_subnet_id = azurerm_subnet.snet_frontend.id

  identity {
    type = "SystemAssigned"
  }
  site_config {
    application_stack {
      node_version = "24"
    }
    always_on = true
    vnet_route_all_enabled = true
    ip_restriction_default_action = "Deny"

    ip_restriction {
      action = "Allow"
      ip_address = "136.255.102.82/32"
      priority = 100
    }
  }

  app_settings = {
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "false"
    "ENABLE_ORYX_BUILD"              = "false"

    "WEBSITE_RUN_FROM_PACKAGE" = "1"
    "AzureWebJobsFeatureFlags" = "EnableWorkerIndexing"
    "FUNCTIONS_WORKER_RUNTIME" = "node"

    "WEBSITE_VNET_ROUTE_ALL" = "1"

    "AzureWebJobsStorage__accountName" = module.stg_func_app.name
  }

  lifecycle {
    ignore_changes = [app_settings["WEBSITE_RUN_FROM_PACKAGE"], app_settings["AzureWebJobsStorage__accountName"], app_settings["WEBSITE_VNET_ROUTE_ALL"], ]
  }
}

resource "azurerm_linux_function_app" "func_app_runner_trigger" {
  name                = "func-app-${var.project_name}-runner-trigger-${var.env}"
  resource_group_name = azurerm_resource_group.rg_todo_func_app.name
  service_plan_id     = azurerm_service_plan.asp_func_apps.id
  location            = azurerm_resource_group.rg_todo_func_app.location

  storage_uses_managed_identity = true
  storage_account_name          = module.stg_func_app.name

  virtual_network_subnet_id = azurerm_subnet.snet_backend.id

  identity {
    type = "SystemAssigned"
  }
  site_config {
    application_stack {
      python_version = "3.12"
    }
    always_on = true
    vnet_route_all_enabled = true
  }

  app_settings = {
    "AzureWebJobsFeatureFlags" = "EnableWorkerIndexing"
    "FUNCTIONS_WORKER_RUNTIME" = "python"

    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
    "Azure_Subscription_Id" = data.azurerm_client_config.current.subscription_id
    "Vm_Resource_Group" = azurerm_resource_group.rg_vm.name
    "Vm_Name" = azurerm_linux_virtual_machine.vm_runner.name
    "AzureWebJobsStorage__accountName" = module.stg_func_app.name

    "env" = var.env
  }

  lifecycle {
    ignore_changes = [ app_settings["AzureWebJobsStorage__accountName"], ]
  }
}