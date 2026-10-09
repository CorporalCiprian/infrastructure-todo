data "azurerm_subscription" "current" {}
#
# Role Assignments
#
resource "azurerm_role_assignment" "runner_scaler_storage" {
  principal_id         = module.func_app_scaler.principal_id
  scope                = module.stg_func_app.id
  role_definition_name = "Storage Blob Data Owner"
}

resource "azurerm_role_assignment" "runner_scaler_queue_storage" {
  principal_id         = module.func_app_scaler.principal_id
  scope                = module.stg_func_app.id
  role_definition_name = "Storage Queue Data Contributor"
}

resource "azurerm_role_assignment" "runner_scaler_table_storage" {
  principal_id         = module.func_app_scaler.principal_id
  scope                = module.stg_func_app.id
  role_definition_name = "Storage Table Data Contributor"
}

resource "azurerm_role_assignment" "runner_scaler_vmss" {
  principal_id         = module.func_app_scaler.principal_id
  scope                = azurerm_linux_virtual_machine_scale_set.vmss_runner.id
  role_definition_name = "Virtual Machine Contributor"
}