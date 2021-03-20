
# Time for me to see what I can create bahahaha :)

# Connect to provider and setting the version
# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

# Athenticating with Azure
provider "azurerm" {
  features {}
}

# Creating a resource group
resource "azurerm_resource_group" "rg" {
  name      = "DELETE_this_GROUP"
  location  = var.location
  tags = var.Devtags
}

# The above works lets build on it!

resource "azurerm_virtual_network" "vnet" {
  name                = "Linux-network"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "snet" {
  name                 = "internal"
  resource_group_name  = "DELETE_this_GROUP"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "nic" {
  name                = "mosya-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vmmosya" {
  name                = "mosya"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  admin_password = var.adminpass
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

   # Copy in the bash script we want to execute.
  # The source is the location of the bash script
  # on the local linux box you are executing terraform
  # from.  The destination is on the new AWS instance.
  provisioner "file" {
    source      = "C:/Users/simpl/OneDrive/Documents/GitHub/Cloud/Terraform/MyTurn/main.ps1"
    destination = "/home/main.ps1"

    connection {
    type     = "winrm"
    user     = "Administrator"
    password = var.adminpass
    host     = var.host
  }
  }
}