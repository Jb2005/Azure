
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
  name     = "GroupForThings"
  location = "eastus2"
}

# The above works lets build on it!
# next lets create a gate way

resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  address_space       = ["10.0.0.0/16"]
  location            = "eastus2"
  resource_group_name = "GroupForThings"
}

resource "azurerm_subnet" "example" {
  name                 = "internal"
  resource_group_name  = "GroupForThings"
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = "eastus2"
  resource_group_name = "GroupForThings"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}