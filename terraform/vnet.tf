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
    address_space = ["10.0.0.0/25"]
}

#
# Subnets
#
resource "azurerm_subnet" "snet_backend" {
    name = "snet-todo-backend"
    resource_group_name = azurerm_resource_group.rg_vnet.name
    virtual_network_name = azurerm_virtual_network.vnet_todo.name
    address_prefixes = [cidrsubnet("10.0.0.0/25",3,0)]

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
    address_prefixes = [cidrsubnet("10.0.0.0/25",3,2)]
    delegation {
      name = "asp-delegation-frontend"

      service_delegation {
        name    = "Microsoft.Web/serverFarms"
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
    private_endpoint_network_policies = "NetworkSecurityGroupEnabled"
}

resource "azurerm_subnet" "snet_stg" {
  name = "snet-todo-stg"
  resource_group_name = azurerm_resource_group.rg_vnet.name
  virtual_network_name = azurerm_virtual_network.vnet_todo.name
  address_prefixes = [cidrsubnet("10.0.0.0/25",3,3)]
}

resource "azurerm_subnet" "snet_db" {
    name = "snet-todo-db"
    resource_group_name = azurerm_resource_group.rg_vnet.name
    virtual_network_name = azurerm_virtual_network.vnet_todo.name
    address_prefixes = [cidrsubnet("10.0.0.0/25",3,1)]
    delegation {
      name = "db-delegation"
      service_delegation {
        name    = "Microsoft.DBforPostgreSQL/flexibleServers"
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    }
    depends_on = [
    azurerm_subnet.snet_backend,
    azurerm_subnet.snet_frontend
  ]
}

#
# Network Security Groups (NSG)
#
resource "azurerm_private_dns_zone_virtual_network_link" "db-dns-link" {
  name                = "db-dns-link"
  resource_group_name = azurerm_resource_group.rg_vnet.name
  private_dns_zone_name = azurerm_private_dns_zone.db_private_dns.name
  virtual_network_id = azurerm_virtual_network.vnet_todo.id
}

#
# Private endpoints
#
resource "azurerm_private_endpoint" "pep_stg_backend" {
  name = "pep-stg-backend"
  subnet_id = azurerm_subnet.snet_stg.id
  location = azurerm_resource_group.rg_vnet.location
  resource_group_name = azurerm_resource_group.rg_vnet.name
  private_service_connection {
    name = "service-conn-backend-stg"
    is_manual_connection = false
    private_connection_resource_id = azurerm_storage_account.stg_func_app_bk.id
  }
}

resource "azurerm_private_endpoint" "pep_stg_frontend" {
  name = "pep-stg-frontend"
  subnet_id = azurerm_subnet.snet_stg.id
  location = azurerm_resource_group.rg_vnet.location
  resource_group_name = azurerm_resource_group.rg_vnet.name
  private_service_connection {
    name = "service-conn-frontend-stg"
    is_manual_connection = false
    private_connection_resource_id = azurerm_storage_account.stg_func_app_fr.id
  }
}

resource "azurerm_private_endpoint" "pep_kv" {
  name = "pep-kv"
  subnet_id = azurerm_subnet.snet_stg.id
  location = azurerm_resource_group.rg_vnet.location
  resource_group_name = azurerm_resource_group.rg_vnet.name
  private_service_connection {
    name = "service-conn-kv"
    is_manual_connection = false
    private_connection_resource_id = azurerm_key_vault.kv_todo.id
  }
  
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
    source_address_prefix = azurerm_subnet.snet_backend.address_prefixes[0]
    source_port_range = "*"
    destination_port_range = "5432"
    destination_address_prefix = azurerm_subnet.snet_db.address_prefixes[0]
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
    destination_address_prefix = azurerm_subnet.snet_db.address_prefixes[0]
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_link_db" {
  subnet_id                 = azurerm_subnet.snet_db.id
  network_security_group_id = azurerm_network_security_group.nsg_db.id
}
