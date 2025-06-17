data "azurerm_virtual_network" "main" {
  name                = var.virtual_network_name
  resource_group_name = local.resource_group_name
}

data "azurerm_network_security_group" "main" {
  name                = "${var.virtual_network_name}-security-group"
  resource_group_name = local.resource_group_name
}

data "azurerm_resource_group" "current" {
  name = local.resource_group_name
}
