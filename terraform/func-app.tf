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
  sku_name            = "P2v2"
  os_type             = "Linux"
}

#
# Func Apps
#
module "func_app_backend" {
  source = "git::https://github.com/CorporalCiprian/terraform-modules//modules/func_apps"
  resource_group_name = azurerm_resource_group.rg_todo_func_app.name
  name = "func-app-${var.project_name}-backend-${var.env}"
  env = var.env
  project_name = var.project_name
  location = var.location
  serviceplan = azurerm_service_plan.asp_func_apps.id
  stgname = module.stg_func_app.name
  subnet_id = module.snets.subnet_ids["backend"]
  app_settings = {
    "FUNCTIONS_WORKER_RUNTIME" = "python"

    "DATABASE_URL" = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.connection_string_db.versionless_id})"

    "ALLOWED_ORIGINS"                  = "https://${module.func_app_frontend.name}.azurewebsites.net"
    "AzureWebJobsStorage__accountName" = module.stg_func_app.name

    "env" = var.env
  }

  site_config = {
    application_stack = {
      python_version = "3.12"
    }
    always_on = true
    vnet_route_all_enabled = true
  }
}

module "func_app_frontend" {
  source = "git::https://github.com/CorporalCiprian/terraform-modules//modules/func_apps"
  resource_group_name = azurerm_resource_group.rg_todo_func_app.name
  project_name = var.project_name
  name = "func-app-${var.project_name}-frontend-${var.env}"
  env = var.env
  location = var.location
  serviceplan = azurerm_service_plan.asp_func_apps.id
  stgname = module.stg_func_app.name
  subnet_id = module.snets.subnet_ids["frontend"]
  app_settings = {
    "WEBSITE_VNET_ROUTE_ALL" = "1"

    "AzureWebJobsStorage__accountName" = module.stg_func_app.name
  }

  site_config = {
    application_stack = {
      node_version = "24"
    }
    always_on = true
    vnet_route_all_enabled = true
  }
}

module "func_app_runner" {
  source = "git::https://github.com/CorporalCiprian/terraform-modules//modules/func_apps"
  resource_group_name = azurerm_resource_group.rg_todo_func_app.name
  name = "func-app-${var.project_name}-runner-${var.env}"
  project_name = var.project_name
  env = var.env
  location = var.location
  serviceplan = azurerm_service_plan.asp_func_apps.id
  stgname = module.stg_func_app.name
  subnet_id = module.snets.subnet_ids["backend"]
  app_settings = {
    "AzureWebJobsFeatureFlags" = "EnableWorkerIndexing"
    "FUNCTIONS_WORKER_RUNTIME" = "python"

    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
    "Azure_Subscription_Id" = data.azurerm_client_config.current.subscription_id
    "Vm_Resource_Group" = azurerm_resource_group.rg_vm.name
    "Vmss_Name" = azurerm_linux_virtual_machine_scale_set.vmss_runner.name
    "AzureWebJobsStorage__accountName" = module.stg_func_app.name

    "env" = var.env
  }

  site_config = {
    application_stack = {
      python_version = "3.12"
    }
    always_on = true
    vnet_route_all_enabled = true
  }
}

module "func_app_scaler" {
  source = "git::https://github.com/CorporalCiprian/terraform-modules//modules/func_apps"
  resource_group_name = azurerm_resource_group.rg_todo_func_app.name
  name = "func-app-${var.project_name}-scaler-${var.env}"
  project_name = var.project_name
  env = var.env
  location = var.location
  serviceplan = azurerm_service_plan.asp_func_apps.id
  stgname = module.stg_func_app.name
  subnet_id = module.snets.subnet_ids["backend"]
  app_settings = {
    "AzureWebJobsFeatureFlags" = "EnableWorkerIndexing"
    "FUNCTIONS_WORKER_RUNTIME" = "python"

    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
    "Azure_Subscription_Id" = data.azurerm_client_config.current.subscription_id
    "Vmss_Resource_Group" = azurerm_resource_group.rg_vm.name
    "Vmss_Name" = azurerm_linux_virtual_machine_scale_set.vmss_runner.name
    "AzureWebJobsStorage__accountName" = module.stg_func_app.name

    "env" = var.env
  }

  site_config = {
    application_stack = {
      python_version = "3.12"
    }
    always_on = true
    vnet_route_all_enabled = true
  }
}