#
# Role Assignments
#
resource "azurerm_role_assignment" "github_principal_kv" {
    principal_id = "896d863f-7800-4972-9ef0-d7b63e09dbcf"
    scope = azurerm_key_vault.kv_todo.id
    role_definition_name = "Key Vault Secrets Officer"
}

data "azurerm_subscription" "current" {}

resource "azurerm_role_assignment" "func_app_role_backend" {
    principal_id = azurerm_linux_function_app.func_todo_backend.identity[0].principal_id
    scope = azurerm_key_vault.kv_todo.id
    role_definition_name = "Key Vault Secrets Officer"
}

resource "azurerm_role_assignment" "func_app_role_frontend" {
    principal_id = azurerm_linux_function_app.func_todo_frontend.identity[0].principal_id
    scope = azurerm_key_vault.kv_todo.id
    role_definition_name = "Key Vault Secrets Officer"
}

resource "azurerm_role_assignment" "github_principal" {
    principal_id = "896d863f-7800-4972-9ef0-d7b63e09dbcf"
    scope = data.azurerm_subscription.current.id
    role_definition_name = "Contributor"
}

resource "azurerm_role_assignment" "backend_app_storage" {
    principal_id = azurerm_linux_function_app.func_todo_backend.identity[0].principal_id
    scope = azurerm_storage_account.stg_func_app_bk.id
    role_definition_name = "Storage Blob Data Owner"
}

resource "azurerm_role_assignment" "frontend_app_storage" {
    principal_id = azurerm_linux_function_app.func_todo_frontend.identity[0].principal_id
    scope = azurerm_storage_account.stg_func_app_fr.id
    role_definition_name = "Storage Blob Data Owner"
}