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
resource "azurerm_subnet" "snet_backend" {
    name = "snet-todo-backend"
    resource_group_name = azurerm_resource_group.rg_vnet.name
    virtual_network_name = azurerm_virtual_network.vnet_todo.name
    address_prefixes = ["10.0.1.0/26"]

    delegation {
      name = "asp-delegation-backend"

      service_delegation {
        name    = "Microsoft.Web/serverFarms"
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
}

resource "azurerm_subnet" "snet_frontend" {
    name = "snet-todo-frontend"
    resource_group_name = azurerm_resource_group.rg_vnet.name
    virtual_network_name = azurerm_virtual_network.vnet_todo.name
    address_prefixes = ["10.0.3.0/26"]

    delegation {
      name = "asp-delegation-frontend"

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

resource "azurerm_subnet" "snet_stg" {
  name = "snet-todo-stg"
  resource_group_name = azurerm_resource_group.rg_vnet.name
  virtual_network_name = azurerm_virtual_network.vnet_todo.name
  address_prefixes = ["10.0.4.0/26"]
}

#
# Network Security Groups (NSG)
#
resource "azurerm_network_security_group" "nsg_db" {
  name = "nsg-db"
  location = azurerm_resource_group.rg_vnet.location
  resource_group_name = azurerm_resource_group.rg_vnet.name

  security_rule {
    name = "allowbackendaccess"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_address_prefix = "10.0.1.0/26"
    source_port_range = "*"
    destination_port_range = "5432"
    destination_address_prefix = "10.0.2.0/26"
  }

  security_rule {
    name = "blockallaccess"
    priority = "4096"
    direction = "Inbound"
    access = "Deny"
    protocol = "*"
    source_address_prefix = "*"
    source_port_range = "*"
    destination_port_range = "*"
    destination_address_prefix = "10.0.2.0/26"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_link_db" {
  subnet_id                 = azurerm_subnet.snet_db.id
  network_security_group_id = azurerm_network_security_group.nsg_db.id
}