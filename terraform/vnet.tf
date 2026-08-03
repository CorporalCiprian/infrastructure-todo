#
# Resource Group
#
resource "azurerm_resource_group" "rg_vnet" {
    name = "rg-vnet"
    location = var.location
}

#
# Vnet
#
resource "azurerm_virtual_network" "vnet_todo" {
    name = "vnet-todo"
    location = azurerm_resource_group.rg_vnet.location
    resource_group_name = azurerm_resource_group.rg_vnet.name
    address_space = ["10.0.0.0/16"]
}

#
# Subnets
#
resource "azurerm_subnet" "snet_apps" {
    name = "snet-todo-apps"
    resource_group_name = azurerm_resource_group.rg_vnet.name
    virtual_network_name = azurerm_virtual_network.vnet_todo.name
    address_prefixes = ["10.0.1.0/26"]

    delegation {
      name = "asp-delegation"

      service_delegation {
        name    = "Microsoft.Web/serverFarms"
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
}

resource "azurerm_subnet" "snet_db" {
    name = "snet-todo-db"
    resource_group_name = azurerm_resource_group.rg_vnet.name
    virtual_network_name = azurerm_virtual_network.vnet_todo.name
    address_prefixes = ["10.0.2.0/26"]
    delegation {
      name = "db-delegation"
      service_delegation {
        name    = "Microsoft.DBforPostgreSQL/flexibleServers"
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    }
}

#
# Private DNS
#
resource "azurerm_private_dns_zone" "db_private_dns" {
    name = "todo.postgres.database.azure.com"
    resource_group_name = azurerm_resource_group.rg_vnet.name
}

#
# DNS links
#
resource "azurerm_private_dns_zone_virtual_network_link" "db-dns-link" {
  name                = "db-dns-link"
  resource_group_name = azurerm_resource_group.rg_vnet.name
  private_dns_zone_name = azurerm_private_dns_zone.db_private_dns.name
  virtual_network_id = azurerm_virtual_network.vnet_todo.id
}