# #
# # Resource Group
# #
# resource "azurerm_resource_group" "rg_vm" {
#   name = "rg-vm-${var.env}"
#   location = "germanywestcentral"
# }
# resource "azurerm_linux_virtual_machine" "vm_runner" {
#   name = "vm-runner-${var.env}"
#   network_interface_ids = [azurerm_network_interface.nic_runner.id]
#   resource_group_name = azurerm_resource_group.rg_vm.name
#   location = azurerm_resource_group.rg_vm.location
#   size = "Standard_D2as_v5"
#   os_disk {
#     storage_account_type = "Standard_LRS"
#     caching = "ReadWrite"
#   }
#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "ubuntu-26_04-lts"
#     sku       = "server"
#     version   = "latest"
#   }
#   admin_username = "adminuser"
#   admin_ssh_key {
#     username = "adminuser"
#     public_key = file("~/.ssh/id_rsa.pub")
#   }
# }

# resource "azurerm_network_interface" "nic_runner" {
#   name = "nic-vm-runner"
#   location = azurerm_resource_group.rg_vnet.location
#   resource_group_name = azurerm_resource_group.rg_vnet.name

#   ip_configuration {
#     name = "ip-config-runner"
#     subnet_id = azurerm_subnet.snet_vm.id
#     private_ip_address_allocation = "Dynamic"
#   }
# }