#
# Resource Group
#
resource "azurerm_resource_group" "rg_vm" {
  name     = "rg-vm-${var.env}"
  location = var.location
}

#
# Vmss
#
resource "azurerm_linux_virtual_machine_scale_set" "vmss_runner" {
  name                = "vmss-runner-${var.env}"
  resource_group_name = azurerm_resource_group.rg_vm.name
  location            = azurerm_resource_group.rg_vm.location
  sku                 = "Standard_B2as_v2"
  instances           = 0
  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
  admin_username = "adminuser"
  admin_password = "abv123.5"
  disable_password_authentication = false
  network_interface {
    name    = "runner-interface"
    primary = true

    ip_configuration {
      name      = "runner-ip-config"
      primary   = true
      subnet_id = module.subnets.subnet_ids["vm"]
    }


  }

  identity {
    type         = "UserAssigned"
    identity_ids = ["/subscriptions/63daad41-14a4-47e4-ac30-399d12e79b3e/resourceGroups/managed-identities/providers/Microsoft.ManagedIdentity/userAssignedIdentities/actions-runner"]
  }
  custom_data = filebase64("vm-cloud-init.yml")

  lifecycle {
    ignore_changes = [instances]
  }
}