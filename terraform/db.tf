#
# Resource Group
#
resource "azurerm_resource_group" "rg_todo_db" {
  name = "rg-${var.project_name}-db-${var.env}"
  location = var.location
}

module "db_module" {
  source = "git::https://github.com/CorporalCiprian/terraform-modules//modules/psqlbd"
  rgname =  azurerm_resource_group.rg_todo_db.name
  location = azurerm_resource_group.rg_todo_db.location
  adminpass = azurerm_key_vault_secret.db_pass.value
  subnet_id = azurerm_subnet.snet_db.id
  dnszone = azurerm_private_dns_zone.db_private_dns.id
  adminname = "postgres"
  sku = "B_Standard_B1ms"
  netaccess = false
}