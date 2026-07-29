data "azurerm_subscription" "student_subscription" {
}
resource "azurerm_role_assignment" "github_principal" {
    principal_id = "896d863f-7800-4972-9ef0-d7b63e09dbcf"
    scope = azurerm_key_vault.kv_todo.id
    role_definition_name = "Key Vault Secrets Officer"
}

resource "azurerm_role_assignment" "func_app_role" {
    principal_id = azurerm_linux_function_app.func_todo_backend.identity[0].principal_id
    scope = azurerm_key_vault.kv_todo.id
    role_definition_name = "Key Vault Secrets Officer"
}