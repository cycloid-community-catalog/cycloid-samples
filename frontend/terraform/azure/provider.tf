variable "organization" {}
variable "project" {}
variable "env" {}
variable "component" {}

# Terraform Azure provider configuration
# See: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
terraform {
  required_providers {
    azurerm = {
      source  = "azurerm"
    }
  }
}

provider "azurerm" {
  environment     = var.azure_env
  client_id       = var.azure_cred.client_id
  client_secret   = var.azure_cred.client_secret
  subscription_id = var.azure_cred.subscription_id
  tenant_id       = var.azure_cred.tenant_id
  features {}
}

variable "azure_cred" {} # { subscription_id, tenant_id, client_id, client_secret }

variable "azure_env" {
  default = "public"
}