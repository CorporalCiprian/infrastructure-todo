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

module "subnets" {
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
    container_apps = {
      address_prefixes = [cidrsubnet("10.0.0.0/25",2,3)]
      service_delegation = true
      delegation_name = "container-delegation-${var.env}"
      service_name = "Microsoft.App/environments"
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

module "registry_dns" {
  source = "git::https://github.com/CorporalCiprian/terraform-modules//modules/virtualnetworking/private_dns"
  dnsname = "privatelink.azurecr.io"
  rgname = azurerm_resource_group.rg_vnet.name
  linkname = "registry-dns-link"
  vnetid = azurerm_virtual_network.vnet_todo.id
}

# module "container_dns" {
#   source = "git::https://github.com/CorporalCiprian/terraform-modules//modules/virtualnetworking/private_dns"
#   dnsname = "calmisland-c12b3b47.westeurope.azurecontainerapps.io"
#   rgname = azurerm_resource_group.rg_vnet.name
#   linkname = "container-environment-link"
#   vnetid = azurerm_virtual_network.vnet_todo.id
# }

# module "backend_dns" {
#   source = "git::https://github.com/CorporalCiprian/terraform-modules//modules/virtualnetworking/private_dns"
#   dnsname = "privatelink.westeurope.azurecontainerapps.io"
#   rgname = azurerm_resource_group.rg_vnet.name
#   linkname = "container-backend-link"
#   vnetid = azurerm_virtual_network.vnet_todo.id
# }


#
# Private endpoints
#
module "pep_blob" {
  source = "git::https://github.com/CorporalCiprian/terraform-modules//modules/virtualnetworking/private_endpoints"
  pepname = "pep-blob-${var.env}"
  subnet_id = module.subnets.subnet_ids["stg"]
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
  subnet_id = module.subnets.subnet_ids["stg"]
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
  subnet_id = module.subnets.subnet_ids["stg"]
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
  subnet_id = module.subnets.subnet_ids["stg"]
  location = azurerm_resource_group.rg_vnet.location
  rgname = azurerm_resource_group.rg_vnet.name
  connectionname = "service-conn-apps-table-${var.env}"
  connectionid = module.stg_func_app.id
  subresource_names = ["table"]
  dnsgroupname = "dns-group-table-${var.env}"
  dnszoneids = [module.table_dns.dns_id]
}

module "pep_registry" {
  source = "git::https://github.com/CorporalCiprian/terraform-modules//modules/virtualnetworking/private_endpoints"
  pepname = "pep-registry-${var.env}"
  subnet_id = module.subnets.subnet_ids["stg"]
  location = azurerm_resource_group.rg_vnet.location
  rgname = azurerm_resource_group.rg_vnet.name
  connectionname = "service-conn-container-registry-${var.env}"
  connectionid = azurerm_container_registry.cr_todo.id
  subresource_names = ["registry"]
  dnsgroupname = "dns-group-registry-${var.env}"
  dnszoneids = [module.registry_dns.dns_id]
}

# module "pep_cae" {
#   source = "git::https://github.com/CorporalCiprian/terraform-modules//modules/virtualnetworking/private_endpoints"
#   pepname = "pep-caea-${var.env}"
#   subnet_id = module.subnets.subnet_ids["stg"]
#   location = azurerm_resource_group.rg_vnet.location
#   rgname = azurerm_resource_group.rg_vnet.name
#   connectionname = "service-conn-container-apps-${var.env}"
#   connectionid = azurerm_container_app_environment.cae_todo.id
#   subresource_names = ["managedEnvironments"]
#   dnsgroupname = "dns-group-containers-${var.env}"
#   dnszoneids = [ module.container_dns.dns_id, module.backend_dns.dns_id ]
# }

# resource "azurerm_private_endpoint" "pep_stg_frontend" {
#   name = "pep-stg-frontend-${var.env}"
#   subnet_id = module.subnets.subnet_ids.id
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
  subnet_id = module.subnets.subnet_ids["stg"]
  location = azurerm_resource_group.rg_vnet.location
  rgname = azurerm_resource_group.rg_vnet.name
  connectionname = "service-conn-apps-kv-${var.env}"
  connectionid = module.key_vault.id
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
      source_address_prefix = module.subnets.address_prefix["backend"]
      source_port_range = "*"
      destination_port_range = "5432"
      destination_address_prefix = module.subnets.address_prefix["db"]
    }
    blockallaccess = {
      priority = "4096"
      direction = "Inbound"
      access = "Deny"
      protocol = "*"
      source_address_prefix = "*"
      source_port_range = "*"
      destination_port_range = "*"
      destination_address_prefix = module.subnets.address_prefix["db"]
    }
  }
}


module "nsg_vm" {
  source = "git::https://github.com/CorporalCiprian/terraform-modules//modules/virtualnetworking/nsg"
  name = "nsg-vm-${var.env}"
  location = azurerm_resource_group.rg_vnet.location
  resource_group_name = azurerm_resource_group.rg_vnet.name

  security_rules = {
  denyallaccess = {
    priority = 4000
    direction = "Inbound"
    access = "Deny"
    protocol = "*"
    source_address_prefix = "*"
    source_port_range = "*"
    destination_port_range = "*"
    destination_address_prefix = module.subnets.address_prefix["vm"]
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

module "nsg_container_apps" {
  source = "git::https://github.com/CorporalCiprian/terraform-modules//modules/virtualnetworking/nsg"
  name = "nsg-container-apps-${var.env}"
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

  allowmyip = {
    priority = "103"
    direction = "Inbound"
    access = "Allow"
    protocol = "*"
    source_address_prefix = "136.255.102.82/32"
    source_port_range = "*"
    destination_port_range = "*"
    destination_address_prefix = "*"
  }

  allowacr = {
    priority = "100"
    direction = "Outbound"
    access = "Allow"
    protocol = "*"
    source_address_prefix = "*"
    source_port_range = "*"
    destination_port_range = "*"
    destination_address_prefix = "AzureContainerRegistry"
  }
  }
}

module "nsg_stg" {
  source = "git::https://github.com/CorporalCiprian/terraform-modules//modules/virtualnetworking/nsg"
  name = "nsg-stg-${var.env}"
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

  allowmyip = {
    priority = "103"
    direction = "Inbound"
    access = "Allow"
    protocol = "*"
    source_address_prefix = "136.255.102.82/32"
    source_port_range = "*"
    destination_port_range = "*"
    destination_address_prefix = "*"
  }
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_link_stg" {
  subnet_id = module.subnets.subnet_ids["stg"]
  network_security_group_id = module.nsg_stg.id  
}
resource "azurerm_subnet_network_security_group_association" "nsg_link_vmnic" {
  subnet_id = module.subnets.subnet_ids["vm"]
  network_security_group_id = module.nsg_vm.id
}
resource "azurerm_subnet_network_security_group_association" "nsg_link_db" {
  subnet_id                 = module.subnets.subnet_ids["db"]
  network_security_group_id = module.nsg_db.id
}

resource "azurerm_subnet_network_security_group_association" "nsg_link_backend" {
  subnet_id = module.subnets.subnet_ids["backend"]
  network_security_group_id = module.nsg_func_apps.id
}

resource "azurerm_subnet_network_security_group_association" "nsg_link_frontend" {
  subnet_id = module.subnets.subnet_ids["frontend"]
  network_security_group_id = module.nsg_func_apps.id
}

resource "azurerm_subnet_network_security_group_association" "nsg_link_containers" {
  subnet_id = module.subnets.subnet_ids["container_apps"]
  network_security_group_id = module.nsg_container_apps.id
}