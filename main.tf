#1. Resource Group and Virtual Network
provider "azurerm" {
  features {}
}
resource "azurerm_resource_group" "rg" {
  name     = "example-resources"
  location = "West Europe"
}
resource "azurerm_virtual_network" "vnet" {
  name                = "example-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_subnet" "subnet" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

#2. Network Security Group (NSG)
resource "azurerm_network_security_group" "nsg" {
  name                = "example-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
resource "azurerm_network_security_rule" "nsg_rule" {
  name                        = "allow-https"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.nsg.name
}

#3. Virtual Machine (VM)
resource "azurerm_windows_virtual_machine" "vm" {
  name                  = "example-vm"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = "Standard_DS1_v2"
  admin_username        = "adminuser"
  admin_password        = "Password1234!"
  network_interface_ids = [azurerm_network_interface.nic.id]
os_disk {
    name              = "example-os-disk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}
resource "azurerm_network_interface" "nic" {
  name                = "example-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}
#4. ExpressRoute
resource "azurerm_express_route_circuit" "erc" {
  name                  = "example-erc"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  service_provider_name = "Equinix"
  peering_location      = "Silicon Valley"
  bandwidth_in_mbps     = 200
sku {
    tier   = "Standard"
    family = "MeteredData"
  }
}
#5. Role-Based Access Control (RBAC)
resource "azurerm_role_assignment" "example" {
  principal_id   = data.azurerm_client_config.current.object_id
  role_definition_name = "Contributor"
  scope          = azurerm_resource_group.rg.id
}
