#
# Resource Group
#
resource "azurerm_resource_group" "rg_todo_kv" {
  name     = "rg-${var.project_name}-kv-${var.env}"
  location = var.location
}

#
# Key Vault
#
module "key_vault" {
  source                     = "git::https://github.com/CorporalCiprian/terraform-modules//modules/kv"
  location                   = azurerm_resource_group.rg_todo_kv.location
  rgname                     = azurerm_resource_group.rg_todo_kv.name
  sku                        = "standard"
  rbac_authorization_enabled = true
  name                       = "kv-${var.project_name}-${var.env}-123"
  enable_secret_expiration_alert = true
  email_receivers = {
    email-alert-1 = "ciprian.gheorghe@bertelsmann.de"
  }
}


#
# Secrets
#
resource "azurerm_key_vault_secret" "connection_string_db" {
  name         = "${var.project_name}-connection-string-${var.env}"
  value        = "postgresql://${module.db_module.administrator_login}:${azurerm_key_vault_secret.db_pass.value}@${module.db_module.fqdn}:5432/${module.db_module.dbnames["todo-db-${var.env}"]}?sslmode=require"
  key_vault_id = module.key_vault.id

  lifecycle {
    ignore_changes = [value]
  }
}

resource "azurerm_key_vault_secret" "db_pass" {
  name         = "${var.project_name}-db-pass-${var.env}"
  value        = "1q2w3e"
  key_vault_id = module.key_vault.id

  lifecycle {
    ignore_changes = [value]
  }
}
