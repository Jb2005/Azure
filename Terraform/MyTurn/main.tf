
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
resource "azurerm_resource_group" "dev" {
  name      = "DELETE_this_GROUP"
  location  = var.location
  tags = var.Devtags
}



resource "azurerm_virtual_network" "vnet" {
  name                = "Linux-network"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.dev.name
}

# Bastion will only work on a subnet called AzureBastionSubnet
# Subnet with name 'AzureBastionSubnet' can be used only for the Azure Bastion resource."
resource "azurerm_subnet" "snet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = "DELETE_this_GROUP"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "nic" {
  name                = "mosya-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.dev.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.snet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Above works lets build on it! 21-03-2021
# Below in is progress.

## Creating the Linux VM
resource "azurerm_linux_virtual_machine" "vmmosya" {
  name                = "mosya"
  resource_group_name = azurerm_resource_group.dev.name
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
# Above works lets build on it! 23-03-2021
# Below in is progress.

# It looks like the below example is not the best route.
# According to the docs for Azure I should use custom_data in the VM set up
  # custom_data "file" {
  #   source      = "C:/Users/simpl/OneDrive/Documents/GitHub/Cloud/Terraform/MyTurn/main.ps1"
  #   destination = "/home/main.ps1"

  #   connection {
  #   type     = "winrm"
  #   user     = "Administrator"
  #   password = var.adminpass
  #   host     = self.public_ip
  # }
  # }
}

## bastion needs a public ip
  resource "azurerm_public_ip" "bastionPublicIP" {
    name                = "examplepip"
    location            = var.location
    resource_group_name = azurerm_resource_group.dev.name
    allocation_method   = "Static"
    sku                 = "Standard"
  }

## setting Bastion for RDP connection.
  resource "azurerm_bastion_host" "example" {
    name                = "bastionConnect"
    location            = var.location
    resource_group_name = azurerm_resource_group.dev.name

    ip_configuration {
      name                 = "configuration"
      subnet_id            = azurerm_subnet.snet.id
      public_ip_address_id = azurerm_public_ip.bastionPublicIP.id
    }
  }