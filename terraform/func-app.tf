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
  sku_name            = "S1"
  os_type             = "Linux"
}

#
# Func Apps
#
module "func_app_scaler" {
  source              = "git::https://github.com/CorporalCiprian/terraform-modules//modules/func_apps"
  resource_group_name = azurerm_resource_group.rg_todo_func_app.name
  name                = "func-app-${var.project_name}-scaler-${var.env}-123"
  project_name        = var.project_name
  env                 = var.env
  location            = var.location
  serviceplan         = azurerm_service_plan.asp_func_apps.id
  stgname             = module.stg_func_app.name
  subnet_id           = module.subnets.subnet_ids["backend"]
  app_settings = {
    "AzureWebJobsFeatureFlags" = "EnableWorkerIndexing"
    "FUNCTIONS_WORKER_RUNTIME" = "python"

    "SCM_DO_BUILD_DURING_DEPLOYMENT"   = "true"
    "Azure_Subscription_Id"            = data.azurerm_client_config.current.subscription_id
    "Vmss_Resource_Group"              = azurerm_resource_group.rg_vm.name
    "Vmss_Name"                        = azurerm_linux_virtual_machine_scale_set.vmss_runner.name
    "AzureWebJobsStorage__accountName" = module.stg_func_app.name

    "env" = var.env
  }
  site_config = {
    application_stack = {
      python_version = "3.12"
    }
    always_on              = true
    vnet_route_all_enabled = true
  } 
}