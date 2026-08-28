#
# Resource Group
#
resource "azurerm_resource_group" "rg_vm" {
  name = "rg-vm-${var.env}"
  location = var.location
}
resource "azurerm_linux_virtual_machine" "vm_runner" {
  name = "vm-runner-${var.env}"
  network_interface_ids = [azurerm_network_interface.nic_runner.id]
  resource_group_name = azurerm_resource_group.rg_vm.name
  location = azurerm_resource_group.rg_vm.location
  size = "Standard_B2as_v2"
  os_disk {
    storage_account_type = "Standard_LRS"
    caching = "ReadWrite"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
  admin_username = "adminuser"
  admin_ssh_key {
    username = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  custom_data = filebase64("vm-cloud-init.yml")
}

resource "azurerm_public_ip" "pip_runner" {
  resource_group_name = azurerm_resource_group.rg_vm.name
  name = "pip-runner-${var.env}"
  location = azurerm_resource_group.rg_vm.location
  allocation_method = "Static"
}

resource "azurerm_network_interface" "nic_runner" {
  name = "nic-vm-runner"
  location = azurerm_resource_group.rg_vnet.location
  resource_group_name = azurerm_resource_group.rg_vnet.name

  ip_configuration {
    name = "ip-config-runner"
    subnet_id = module.snets.subnet_ids["vm"]
    private_ip_address_allocation = "Static"
    public_ip_address_id = azurerm_public_ip.pip_runner.id
  }
}