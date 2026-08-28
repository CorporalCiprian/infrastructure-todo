#
# Resource Group
#
resource "azurerm_resource_group" "rg_vnet" {
    name = "rg-vnet-${var.env}"
    location = var.location
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

module "snets" {
  source = "git::https://github.com/CorporalCiprian/terraform-modules//modules/virtualnetworking/subnets"
  resource_group_name = azurerm_resource_group.rg_vnet.name
  virtual_network_name = azurerm_virtual_network.vnet_todo.name
  subnets = {
    backend = {
      address_prefixes = [cidrsubnet("10.0.0.0/25",3,0)]
      service_delegation = true
      delegation_name = "asp-delegation-backend-${var.env}"
      service_name = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
    frontend = {
      address_prefixes = [cidrsubnet("10.0.0.0/25",3,2)]
      service_delegation = true
      delegation_name = "asp-delegation-frontend-${var.env}"
      service_name = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
    stg = {
      address_prefixes = [cidrsubnet("10.0.0.0/25",3,3)]
    }
    db = {
      address_prefixes = [cidrsubnet("10.0.0.0/25",3,1)]
      service_delegation = true
      delegation_name = "db-delegation-${var.env}"
      service_name = "Microsoft.DBforPostgreSQL/flexibleServers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
    vm = {
      address_prefixes = [cidrsubnet("10.0.0.0/25",3,4)]
    }
  }
}
#
# Private DNS
#
module "db_dns" {
  source = "git::https://github.com/CorporalCiprian/terraform-modules//modules/virtualnetworking/private_dns"
  dnsname = "privatelink.postgres.database.azure.com"
  rgname = azurerm_resource_group.rg_vnet.name
  linkname = "db-dns-link"
  vnetid = azurerm_virtual_network.vnet_todo.id
}

module "kv_dns" {
  source = "git::https://github.com/CorporalCiprian/terraform-modules//modules/virtualnetworking/private_dns"
  dnsname = "privatelink.vaultcore.azure.net"
  rgname = azurerm_resource_group.rg_vnet.name
  linkname = "kv-dns-link"
  vnetid = azurerm_virtual_network.vnet_todo.id
}

module "blob_dns" {
  source = "git::https://github.com/CorporalCiprian/terraform-modules//modules/virtualnetworking/private_dns"
  dnsname = "privatelink.blob.core.windows.net"
  rgname = azurerm_resource_group.rg_vnet.name
  linkname = "blob-dns-link"
  vnetid = azurerm_virtual_network.vnet_todo.id
}

module "file_dns" {
  source = "git::https://github.com/CorporalCiprian/terraform-modules//modules/virtualnetworking/private_dns"
  dnsname = "privatelink.file.core.windows.net"
  rgname = azurerm_resource_group.rg_vnet.name
  linkname = "file-dns-link"
  vnetid = azurerm_virtual_network.vnet_todo.id
}

module "queue_dns" {
  source = "git::https://github.com/CorporalCiprian/terraform-modules//modules/virtualnetworking/private_dns"
  dnsname = "privatelink.queue.core.windows.net"
  rgname = azurerm_resource_group.rg_vnet.name
  linkname = "queue-dns-link"
  vnetid = azurerm_virtual_network.vnet_todo.id
}

module "table_dns" {
  source = "git::https://github.com/CorporalCiprian/terraform-modules//modules/virtualnetworking/private_dns"
  dnsname = "privatelink.table.core.windows.net"
  rgname = azurerm_resource_group.rg_vnet.name
  linkname = "table-dns-link"
  vnetid = azurerm_virtual_network.vnet_todo.id
}



#
# Private endpoints
#
module "pep_blob" {
  source = "git::https://github.com/CorporalCiprian/terraform-modules//modules/virtualnetworking/private_endpoints"
  pepname = "pep-blob-${var.env}"
  subnet_id = module.snets.subnet_ids["stg"]
  location = azurerm_resource_group.rg_vnet.location
  rgname = azurerm_resource_group.rg_vnet.name
  connectionname = "service-conn-apps-blob-${var.env}"
  connectionid = module.stg_func_app.id
  subresource_names = ["blob"]
  dnsgroupname = "dns-group-blob-${var.env}"
  dnszoneids = [module.blob_dns.dns_id]
}

module "pep_file" {
  source = "git::https://github.com/CorporalCiprian/terraform-modules//modules/virtualnetworking/private_endpoints"
  pepname = "pep-file-${var.env}"
  subnet_id = module.snets.subnet_ids["stg"]
  location = azurerm_resource_group.rg_vnet.location
  rgname = azurerm_resource_group.rg_vnet.name
  connectionname = "service-conn-apps-file-${var.env}"
  connectionid = module.stg_func_app.id
  subresource_names = ["file"]
  dnsgroupname = "dns-group-file-${var.env}"
  dnszoneids = [module.file_dns.dns_id]
}

module "pep_queue" {
  source = "git::https://github.com/CorporalCiprian/terraform-modules//modules/virtualnetworking/private_endpoints"
  pepname = "pep-queue-${var.env}"
  subnet_id = module.snets.subnet_ids["stg"]
  location = azurerm_resource_group.rg_vnet.location
  rgname = azurerm_resource_group.rg_vnet.name
  connectionname = "service-conn-apps-queue-${var.env}"
  connectionid = module.stg_func_app.id
  subresource_names = ["queue"]
  dnsgroupname = "dns-group-queue-${var.env}"
  dnszoneids = [module.queue_dns.dns_id]
}

module "pep_table" {
  source = "git::https://github.com/CorporalCiprian/terraform-modules//modules/virtualnetworking/private_endpoints"
  pepname = "pep-table-${var.env}"
  subnet_id = module.snets.subnet_ids["stg"]
  location = azurerm_resource_group.rg_vnet.location
  rgname = azurerm_resource_group.rg_vnet.name
  connectionname = "service-conn-apps-table-${var.env}"
  connectionid = module.stg_func_app.id
  subresource_names = ["table"]
  dnsgroupname = "dns-group-table-${var.env}"
  dnszoneids = [module.table_dns.dns_id]
}

# resource "azurerm_private_endpoint" "pep_stg_frontend" {
#   name = "pep-stg-frontend-${var.env}"
#   subnet_id = module.snets.subnet_ids.id
#   location = azurerm_resource_group.rg_vnet.location
#   resource_group_name = azurerm_resource_group.rg_vnet.name
#   private_service_connection {
#     name = "service-conn-frontend-stg-${var.env}"
#     is_manual_connection = false
#     private_connection_resource_id = azurerm_storage_account.stg_func_app_fr.id
#   }
# }

module "pep_kv" {
  source = "git::https://github.com/CorporalCiprian/terraform-modules//modules/virtualnetworking/private_endpoints"
  pepname = "pep-kv-${var.env}"
  subnet_id = module.snets.subnet_ids["stg"]
  location = azurerm_resource_group.rg_vnet.location
  rgname = azurerm_resource_group.rg_vnet.name
  connectionname = "service-conn-apps-kv-${var.env}"
  connectionid = module.stg_func_app.id
  subresource_names = ["vault"]
  dnsgroupname = "dns-group-kv-${var.env}"
  dnszoneids = [module.kv_dns.dns_id]
}

#
# Network Security Groups (NSG)
#


module "nsg_db" {
  source = "git::https://github.com/CorporalCiprian/terraform-modules//modules/virtualnetworking/nsg"
  name = "nsg-db-${var.env}"
  location = azurerm_resource_group.rg_vnet.location
  resource_group_name = azurerm_resource_group.rg_vnet.name

  security_rules = {
    backend = {
      priority = 100
      direction = "Inbound"
      access = "Allow"
      protocol = "Tcp"
      source_address_prefix = module.snets.address_prefix["backend"]
      source_port_range = "*"
      destination_port_range = "5432"
      destination_address_prefix = module.snets.address_prefix["db"]
    }
    blockallaccess = {
      priority = "4096"
      direction = "Inbound"
      access = "Deny"
      protocol = "*"
      source_address_prefix = "*"
      source_port_range = "*"
      destination_port_range = "*"
      destination_address_prefix = module.snets.address_prefix["db"]
    }
  }
}


module "nsg_vm" {
  source = "git::https://github.com/CorporalCiprian/terraform-modules//modules/virtualnetworking/nsg"
  name = "nsg-vm-${var.env}"
  location = azurerm_resource_group.rg_vnet.location
  resource_group_name = azurerm_resource_group.rg_vnet.name

  security_rules = {
    allowmyipaccess = {
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "*"
    source_address_prefix = "136.255.102.82/32"
    source_port_range = "*"
    destination_port_range = "*"
    destination_address_prefix = azurerm_public_ip.pip_runner.ip_address 
  }

  denyallaccess = {
    priority = 4000
    direction = "Inbound"
    access = "Deny"
    protocol = "*"
    source_address_prefix = "*"
    source_port_range = "*"
    destination_port_range = "*"
    destination_address_prefix = azurerm_public_ip.pip_runner.ip_address
  }

  SSH = {
    priority = "101"
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_address_prefix = "136.255.102.82/32"
    source_port_range = "*"
    destination_port_range = "22"
    destination_address_prefix = "*"
  }

  allowazure = {
    priority = "102"
    direction = "Inbound"
    access = "Allow"
    protocol = "*"
    source_address_prefix = "AzureCloud"
    source_port_range = "*"
    destination_port_range = "*"
    destination_address_prefix = "*"
  }
  }
}

module "nsg_func_apps" {
  source = "git::https://github.com/CorporalCiprian/terraform-modules//modules/virtualnetworking/nsg"
  name = "nsg-func-apps-${var.env}"
  location = azurerm_resource_group.rg_vnet.location
  resource_group_name = azurerm_resource_group.rg_vnet.name

  security_rules = {
    denyallaccess = {
    priority = "4000"
    direction = "Inbound"
    access = "Deny"
    protocol = "*"
    source_address_prefix = "*"
    source_port_range = "*"
    destination_port_range = "*"
    destination_address_prefix = "*"
  }

  allowmyip = {
    priority = "100"
    direction = "Inbound"
    access = "Allow"
    protocol = "*"
    source_address_prefix = "86.123.225.82/32"
    source_port_range = "*"
    destination_address_prefix = "*"
    destination_port_range = "*"
  }

  allowazure = {
    priority = "102"
    direction = "Inbound"
    access = "Allow"
    protocol = "*"
    source_address_prefix = "AzureCloud"
    source_port_range = "*"
    destination_port_range = "*"
    destination_address_prefix = "*"
  }
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_link_vmnic" {
  network_interface_id = azurerm_network_interface.nic_runner.id
  network_security_group_id = module.nsg_vm.id
}
resource "azurerm_subnet_network_security_group_association" "nsg_link_db" {
  subnet_id                 = module.snets.subnet_ids["db"]
  network_security_group_id = module.nsg_db.id
}

resource "azurerm_subnet_network_security_group_association" "nsg_link_backend" {
  subnet_id = module.snets.subnet_ids["backend"]
  network_security_group_id = module.nsg_func_apps.id
}

resource "azurerm_subnet_network_security_group_association" "nsg_link_frontend" {
  subnet_id = module.snets.subnet_ids["frontend"]
  network_security_group_id = module.nsg_func_apps.id
}