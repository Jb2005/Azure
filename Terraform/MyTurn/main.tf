
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
  tags = var.tags
}

# The above works lets build on it!

resource "azurerm_virtual_network" "vnet" {
  name                = "vnetforfun"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  tags                = var.tags
  resource_group_name = azurerm_resource_group.rg.name
  
}