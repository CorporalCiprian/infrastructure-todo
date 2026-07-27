locals {
  kv_access_type = {
    "user" = "bb0514bf-e920-4ad4-855a-1e7be403d253"
    "sp_github" = "896d863f-7800-4972-9ef0-d7b63e09dbcf"
  }
}

resource "azurerm_key_vault_access_policy" "kv_ap" {
  key_vault_id = azurerm_key_vault.kv_todo.id
  tenant_id    = data.azurerm_client_config.current.tenant_id

  for_each        = local.kv_access_type
  object_id       = each.value
  key_permissions = var.key_permissions

  secret_permissions = var.secret_permissions
}

resource "azurerm_key_vault_access_policy" "kv-ap-func" {
  key_vault_id = azurerm_key_vault.kv_todo.id
  tenant_id    = data.azurerm_client_config.current.tenant_id

  object_id       = azurerm_linux_function_app.func_todo_backend.identity[0].principal_id
  key_permissions = var.key_permissions

  secret_permissions = var.secret_permissions
}