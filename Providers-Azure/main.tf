terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.20.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {
    # Enable the Azure Resource Manager provider
    # resource_manager = true 
  }
}

