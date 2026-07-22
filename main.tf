resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

resource "azurerm_resource_group" "rg-test" {
  location = var.location
  name     = random_pet.rg_name.id
}

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

data "azurerm_client_config" "current" {}

resource "random_string" "azurerm_key_vault_name" {
  length  = 13
  lower   = true
  numeric = false
  special = false
  upper   = false
}

resource "azurerm_key_vault_access_policy" "kv-ap" {
  key_vault_id = azurerm_key_vault.kv-db.id
  tenant_id    = data.azurerm_client_config.current.tenant_id

  for_each        = local.kv_access_type
  object_id       = each.value.object_id
  key_permissions = each.value.key_permissions

  secret_permissions = each.value.secret_permissions
}

resource "azurerm_key_vault" "kv-db" {
  name                       = coalesce(var.vault_name, "kv-${random_string.azurerm_key_vault_name.result}")
  location                   = azurerm_resource_group.rg-test.location
  resource_group_name        = azurerm_resource_group.rg-test.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = var.sku_name
  soft_delete_retention_days = 7
}

resource "azurerm_key_vault_secret" "secret-test" {
  name         = "connection-string"
  value        = var.connection_string_value
  key_vault_id = azurerm_key_vault.kv-db.id

  lifecycle {
    ignore_changes = [value]
  }

  depends_on = [azurerm_key_vault_access_policy.kv-ap]
}

resource "azurerm_resource_group" "rg-sp" {
  location = var.location
  name     = "${random_pet.rg_name.id}-service-principal"
}