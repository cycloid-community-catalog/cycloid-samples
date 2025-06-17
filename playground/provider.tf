terraform {
  backend "http" {}

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=4.32.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">=3.7.2"
    }
  }

  required_version = ">=0.12.0"
}

provider "azurerm" {
  features {}
  resource_provider_registrations = "all"
}

# resource "azurerm_resource_provider_registration" "azureterraform" {
#   name = "Microsoft.AzureTerraform"
# }
