variable "organization" { type = string }
variable "project" { type = string }
variable "env" { type = string }
variable "component" { type = string }


# Terraform Azure provider configuration
# See: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
terraform {
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

variable "azure_cred" {
  type = object({
    client_id       = string
    client_secret   = string
    subscription_id = string
    tenant_id       = string
  })

} # { subscription_id, tenant_id, client_id, client_secret }
provider "azurerm" {
  features {}
  environment                     = var.azure_env
  client_id                       = var.azure_cred.client_id
  client_secret                   = var.azure_cred.client_secret
  subscription_id                 = var.azure_cred.subscription_id
  tenant_id                       = var.azure_cred.tenant_id
  resource_provider_registrations = "all"
}


variable "azure_env" {
  type    = string
  default = "public"
}

