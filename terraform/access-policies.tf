locals {
  kv_access_type = {
    "user" = {
      object_id          = "bb0514bf-e920-4ad4-855a-1e7be403d253"
      secret_permissions = var.secret_permissions
      key_permissions    = var.key_permissions
    }
    "sp_github" = {
      object_id          = "896d863f-7800-4972-9ef0-d7b63e09dbcf"
      secret_permissions = var.secret_permissions
      key_permissions    = var.key_permissions
    }
  }
}

resource "azurerm_key_vault_access_policy" "kv_ap" {
  key_vault_id = azurerm_key_vault.kv_todo.id
  tenant_id    = data.azurerm_client_config.current.tenant_id

  for_each        = local.kv_access_type
  object_id       = each.value.object_id
  key_permissions = each.value.key_permissions

  secret_permissions = each.value.secret_permissions
}