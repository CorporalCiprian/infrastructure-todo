#
# Role Assignments
#
resource "azurerm_role_assignment" "github_principal_kv" {
    principal_id = "896d863f-7800-4972-9ef0-d7b63e09dbcf"
    scope = module.key_vault.id
    role_definition_name = "Key Vault Secrets Officer"
}

data "azurerm_subscription" "current" {}

resource "azurerm_role_assignment" "func_app_role_backend" {
    principal_id = module.func_app_backend.principal_id
    scope = module.key_vault.id
    role_definition_name = "Key Vault Secrets Officer"
}

resource "azurerm_role_assignment" "func_app_role_frontend" {
    principal_id = module.func_app_frontend.principal_id
    scope = module.key_vault.id
    role_definition_name = "Key Vault Secrets Officer"
}

resource "azurerm_role_assignment" "github_principal" {
    principal_id = "896d863f-7800-4972-9ef0-d7b63e09dbcf"
    scope = data.azurerm_subscription.current.id
    role_definition_name = "Contributor"
}

resource "azurerm_role_assignment" "backend_app_storage" {
    principal_id = module.func_app_backend.principal_id
    scope = module.stg_func_app.id
    role_definition_name = "Storage Blob Data Owner"
}

resource "azurerm_role_assignment" "frontend_app_storage" {
    principal_id = module.func_app_frontend.principal_id
    scope = module.stg_func_app.id
    role_definition_name = "Storage Blob Data Owner"
}

# resource "azurerm_role_assignment" "runner_trigger_vm" {
#   principal_id = module.func_app_runner.principal_id
#   scope = azurerm_linux_virtual_machine.vm_runner.id
#   role_definition_name = "Virtual Machine Contributor"
# }

# resource "azurerm_role_assignment" "runner_trigger_storage" {
#   principal_id = module.func_app_runner.principal_id
#   scope = module.stg_func_app.id
#   role_definition_name = "Storage Blob Data Owner"
# }

resource "azurerm_role_assignment" "runner_scaler_storage" {
  principal_id = module.func_app_scaler.principal_id
  scope = module.stg_func_app.id
  role_definition_name = "Storage Blob Data Owner"
}

resource "azurerm_role_assignment" "runner_scaler_queue_storage" {
  principal_id = module.func_app_scaler.principal_id
  scope = module.stg_func_app.id
  role_definition_name = "Storage Queue Data Contributor"
}

resource "azurerm_role_assignment" "runner_scaler_table_storage" {
  principal_id = module.func_app_scaler.principal_id
  scope = module.stg_func_app.id
  role_definition_name = "Storage Table Data Contributor"
}

resource "azurerm_role_assignment" "runner_scaler_vmss" {
  principal_id = module.func_app_scaler.principal_id
  scope = azurerm_linux_virtual_machine_scale_set.vmss_runner.id
  role_definition_name = "Virtual Machine Contributor"
}

resource "azurerm_role_assignment" "github_principal_runner" {
    principal_id = "d6365aa0-c31d-4a02-8fad-8e28a12fefdd"
    scope = azurerm_resource_group.rg_vm.id
    role_definition_name = "Virtual Machine Contributor"
}

resource "azurerm_role_assignment" "runner_kv" {
  principal_id = "d6365aa0-c31d-4a02-8fad-8e28a12fefdd"
  scope = azurerm_resource_group.rg_todo_kv.id
  role_definition_name = "Key Vault Secrets Officer" 
}