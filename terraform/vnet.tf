#
# Resource Group
#
resource "azurerm_resource_group" "rg_vnet" {
    name = "rg-vnet-${var.env}"
    location = "germanywestcentral"
}

#
# Vnet
#
resource "azurerm_virtual_network" "vnet_todo" {
    name = "vnet-todo-${var.env}"
    location = azurerm_resource_group.rg_vnet.location
    resource_group_name = azurerm_resource_group.rg_vnet.name
    address_space = ["10.0.0.0/25"]
}

#
# Subnets
#
resource "azurerm_subnet" "snet_backend" {
    name = "snet-todo-backend-${var.env}"
    resource_group_name = azurerm_resource_group.rg_vnet.name
    virtual_network_name = azurerm_virtual_network.vnet_todo.name
    address_prefixes = [cidrsubnet("10.0.0.0/25",3,0)]

    delegation {
      name = "asp-delegation-backend-${var.env}"

      service_delegation {
        name    = "Microsoft.Web/serverFarms"
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
}

resource "azurerm_subnet" "snet_frontend" {
    name = "snet-todo-frontend-${var.env}"
    resource_group_name = azurerm_resource_group.rg_vnet.name
    virtual_network_name = azurerm_virtual_network.vnet_todo.name
    address_prefixes = [cidrsubnet("10.0.0.0/25",3,2)]
    delegation {
      name = "asp-delegation-frontend-${var.env}"

      service_delegation {
        name    = "Microsoft.Web/serverFarms"
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
    private_endpoint_network_policies = "NetworkSecurityGroupEnabled"
}

resource "azurerm_subnet" "snet_stg" {
  name = "snet-todo-stg-${var.env}"
  resource_group_name = azurerm_resource_group.rg_vnet.name
  virtual_network_name = azurerm_virtual_network.vnet_todo.name
  address_prefixes = [cidrsubnet("10.0.0.0/25",3,3)]
}

resource "azurerm_subnet" "snet_db" {
    name = "snet-todo-db-${var.env}"
    resource_group_name = azurerm_resource_group.rg_vnet.name
    virtual_network_name = azurerm_virtual_network.vnet_todo.name
    address_prefixes = [cidrsubnet("10.0.0.0/25",3,1)]
    delegation {
      name = "db-delegation-${var.env}"
      service_delegation {
        name    = "Microsoft.DBforPostgreSQL/flexibleServers"
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
      }
    }
}

# resource "azurerm_subnet" "snet_vm" {
#   name = "snet-vm-${var.env}"
#   resource_group_name = azurerm_resource_group.rg_vnet.name
#   virtual_network_name = azurerm_virtual_network.vnet_todo.name
#   address_prefixes = [cidrsubnet("10.0.0.0/25",3,4)]
# }
#
# Private DNS
#
resource "azurerm_private_dns_zone" "db_private_dns" {
  name="privatelink.postgres.database.azure.com"
  resource_group_name = azurerm_resource_group.rg_vnet.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "db_dns_link" {
  name                = "db-dns-link-${var.env}"
  resource_group_name = azurerm_resource_group.rg_vnet.name
  private_dns_zone_name = azurerm_private_dns_zone.db_private_dns.name
  virtual_network_id = azurerm_virtual_network.vnet_todo.id
}

resource "azurerm_private_dns_zone" "kv_private_dns" {
  name="privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.rg_vnet.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "kv_dns_link" {
  name                = "kv-dns-link-${var.env}"
  resource_group_name = azurerm_resource_group.rg_vnet.name
  private_dns_zone_name = azurerm_private_dns_zone.kv_private_dns.name
  virtual_network_id = azurerm_virtual_network.vnet_todo.id
}

resource "azurerm_private_dns_zone" "stg_blob_dns" {
  name="privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg_vnet.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "stg_blob_dns_link" {
  name                = "blob-dns-link-${var.env}"
  resource_group_name = azurerm_resource_group.rg_vnet.name
  private_dns_zone_name = azurerm_private_dns_zone.stg_blob_dns.name
  virtual_network_id = azurerm_virtual_network.vnet_todo.id
}

resource "azurerm_private_dns_zone" "stg_file_dns" {
  name="privatelink.file.core.windows.net"
  resource_group_name = azurerm_resource_group.rg_vnet.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "stg_file_dns_link" {
  name                = "file-dns-link-${var.env}"
  resource_group_name = azurerm_resource_group.rg_vnet.name
  private_dns_zone_name = azurerm_private_dns_zone.stg_file_dns.name
  virtual_network_id = azurerm_virtual_network.vnet_todo.id
}

resource "azurerm_private_dns_zone" "stg_queue_dns" {
  name="privatelink.queue.core.windows.net"
  resource_group_name = azurerm_resource_group.rg_vnet.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "stg_queue_dns_link" {
  name                = "queue-dns-link-${var.env}"
  resource_group_name = azurerm_resource_group.rg_vnet.name
  private_dns_zone_name = azurerm_private_dns_zone.stg_queue_dns.name
  virtual_network_id = azurerm_virtual_network.vnet_todo.id
}

resource "azurerm_private_dns_zone" "stg_table_dns" {
  name="privatelink.table.core.windows.net"
  resource_group_name = azurerm_resource_group.rg_vnet.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "stg_table_dns_link" {
  name                = "table-dns-link-${var.env}"
  resource_group_name = azurerm_resource_group.rg_vnet.name
  private_dns_zone_name = azurerm_private_dns_zone.stg_table_dns.name
  virtual_network_id = azurerm_virtual_network.vnet_todo.id
}



#
# Private endpoints
#
resource "azurerm_private_endpoint" "pep_blob" {
  name = "pep-blob-backend-${var.env}"
  subnet_id = azurerm_subnet.snet_stg.id
  location = azurerm_resource_group.rg_vnet.location
  resource_group_name = azurerm_resource_group.rg_vnet.name
  private_service_connection {
    name = "service-conn-apps-blob-${var.env}"
    is_manual_connection = false
    private_connection_resource_id = azurerm_storage_account.stg_func_app.id
    subresource_names = ["blob"]
  }
  private_dns_zone_group {
    name = "dns-group-blob-${var.env}"
    private_dns_zone_ids = [azurerm_private_dns_zone.stg_blob_dns.id]
  }

  depends_on = [ azurerm_private_dns_zone_virtual_network_link.stg_blob_dns_link ]
}

resource "azurerm_private_endpoint" "pep_file" {
  name = "pep-file-backend-${var.env}"
  subnet_id = azurerm_subnet.snet_stg.id
  location = azurerm_resource_group.rg_vnet.location
  resource_group_name = azurerm_resource_group.rg_vnet.name
  private_service_connection {
    name = "service-conn-apps-file-${var.env}"
    is_manual_connection = false
    private_connection_resource_id = azurerm_storage_account.stg_func_app.id
    subresource_names = ["file"]
  }
  private_dns_zone_group {
    name = "dns-group-file-${var.env}"
    private_dns_zone_ids = [azurerm_private_dns_zone.stg_file_dns.id]
  }

  depends_on = [ azurerm_private_dns_zone_virtual_network_link.stg_file_dns_link, azurerm_private_endpoint.pep_blob ]
}

resource "azurerm_private_endpoint" "pep_queue" {
  name = "pep-queue-backend-${var.env}"
  subnet_id = azurerm_subnet.snet_stg.id
  location = azurerm_resource_group.rg_vnet.location
  resource_group_name = azurerm_resource_group.rg_vnet.name
  private_service_connection {
    name = "service-conn-apps-queue-${var.env}"
    is_manual_connection = false
    private_connection_resource_id = azurerm_storage_account.stg_func_app.id
    subresource_names = ["queue"]
  }
  private_dns_zone_group {
    name = "dns-group-queue-${var.env}"
    private_dns_zone_ids = [azurerm_private_dns_zone.stg_queue_dns.id]
  }

  depends_on = [ azurerm_private_dns_zone_virtual_network_link.stg_queue_dns_link, azurerm_private_endpoint.pep_file ]
}

resource "azurerm_private_endpoint" "pep_table" {
  name = "pep-table-backend-${var.env}"
  subnet_id = azurerm_subnet.snet_stg.id
  location = azurerm_resource_group.rg_vnet.location
  resource_group_name = azurerm_resource_group.rg_vnet.name
  private_service_connection {
    name = "service-conn-apps-table-${var.env}"
    is_manual_connection = false
    private_connection_resource_id = azurerm_storage_account.stg_func_app.id
    subresource_names = ["table"]
  }
  private_dns_zone_group {
    name = "dns-group-table-${var.env}"
    private_dns_zone_ids = [azurerm_private_dns_zone.stg_table_dns.id]
  }

  depends_on = [ azurerm_private_dns_zone_virtual_network_link.stg_table_dns_link, azurerm_private_endpoint.pep_queue ]
}

# resource "azurerm_private_endpoint" "pep_stg_frontend" {
#   name = "pep-stg-frontend-${var.env}"
#   subnet_id = azurerm_subnet.snet_stg.id
#   location = azurerm_resource_group.rg_vnet.location
#   resource_group_name = azurerm_resource_group.rg_vnet.name
#   private_service_connection {
#     name = "service-conn-frontend-stg-${var.env}"
#     is_manual_connection = false
#     private_connection_resource_id = azurerm_storage_account.stg_func_app_fr.id
#   }
# }

resource "azurerm_private_endpoint" "pep_kv" {
  name = "pep-kv"
  subnet_id = azurerm_subnet.snet_stg.id
  location = azurerm_resource_group.rg_vnet.location
  resource_group_name = azurerm_resource_group.rg_vnet.name
  private_service_connection {
    name = "service-conn-kv"
    is_manual_connection = false
    private_connection_resource_id = azurerm_key_vault.kv_todo.id
    subresource_names = ["vault"]
  }
  private_dns_zone_group {
    name = "dns-group-kv"
    private_dns_zone_ids = [azurerm_private_dns_zone.kv_private_dns.id]
  }

  depends_on = [ azurerm_private_dns_zone_virtual_network_link.kv_dns_link ]
}

#
# Network Security Groups (NSG)
#
resource "azurerm_network_security_group" "nsg_db" {
  name = "nsg-db-${var.env}"
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
