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
module "func_app_backend" {
  source = "git::https://github.com/CorporalCiprian/terraform-modules//modules/func-apps/backend"
  resource_group_name = azurerm_resource_group.rg_todo_func_app.name
  project_name = var.project_name
  env = var.env
  location = var.location
  serviceplan = azurerm_service_plan.asp_func_apps.id
  stgname = module.stg_func_app.name
  subnet_id = azurerm_subnet.snet_backend.id
  networkaccess = "private"
  allowedorigins = "https://${module.func_app_frontend.name}.azurewebsites.net"
  build_in_azure = false
  db_url = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.connection_string_db.versionless_id})"
}

module "func_app_frontend" {
  source = "git::https://github.com/CorporalCiprian/terraform-modules//modules/func-apps/frontend"
  resource_group_name = azurerm_resource_group.rg_todo_func_app.name
  project_name = var.project_name
  env = var.env
  location = var.location
  serviceplan = azurerm_service_plan.asp_func_apps.id
  stgname = module.stg_func_app.name
  subnet_id = azurerm_subnet.snet_frontend.id
  build_in_azure = false
  networkaccess = "private"
}

module "func_app_runner" {
  source = "git::https://github.com/CorporalCiprian/terraform-modules//modules/func-apps/runner"
  resource_group_name = azurerm_resource_group.rg_todo_func_app.name
  project_name = var.project_name
  env = var.env
  location = var.location
  serviceplan = azurerm_service_plan.asp_func_apps.id
  stgname = module.stg_func_app.name
  subnet_id = azurerm_subnet.snet_backend.id
  networkaccess = "private"
  subscription_id = data.azurerm_client_config.current.subscription_id
  vm_rg = azurerm_resource_group.rg_vm.name
  vm_name = azurerm_linux_virtual_machine.vm_runner.name
  build_in_azure = true
}