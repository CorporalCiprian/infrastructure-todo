resource "random_pet" "rg_name" {
  prefix= var.resource_group_name_prefix
}

resource "azurerm_resource_group" "rg-test" {
  location = var.location
  name     = random_pet.rg_name.id
}

data "azurerm_client_config" "current" {}

resource "random_string" "azurerm_key_vault_name" {
  length  = 13
  lower   = true
  numeric = false
  special = false
  upper   = false
}

resource "azurerm_key_vault" "kv-db" {
  name                       = coalesce(var.vault_name, "kv-${random_string.azurerm_key_vault_name.result}")
  location                   = azurerm_resource_group.rg-test.location
  resource_group_name        = azurerm_resource_group.rg-test.name
  tenant_id    = data.azurerm_client_config.current.tenant_id
  sku_name                   = var.sku_name
  soft_delete_retention_days = 7
}

resource "azurerm_key_vault_access_policy" "kv-ap" {
  key_vault_id = azurerm_key_vault.kv-db.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = var.key_permissions

  secret_permissions = var.secret_permissions
}

resource "azurerm_key_vault_secret" "secret-test" {
  name         = "connection-string"
  value        = var.connection_string_value
  key_vault_id = azurerm_key_vault.kv-db.id

  depends_on = [azurerm_key_vault_access_policy.kv-ap]
  
  lifecycle {
    ignore_changes = [value]
  }
}

resource "azurerm_resource_group" "rg-sp" {
  location= var.location
  name= "${random_pet.rg_name.id}-service-principal"
}