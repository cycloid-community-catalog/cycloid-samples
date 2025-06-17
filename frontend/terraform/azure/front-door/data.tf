locals {
  resource_group_name = "${var.organization}-${var.project}-${var.environment}"
}

data "azurerm_resource_group" "current" {
  name = local.resource_group_name
}

data "azurerm_container_app" "app" {
  name                = var.container_app_name
  resource_group_name = local.resource_group_name
}
