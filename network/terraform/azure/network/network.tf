resource "azurerm_resource_group" "current" {
  name     = "${var.organization}-${var.project}-${var.environment}"
  location = var.location
  tags     = local.default_tags
}

resource "azurerm_virtual_network" "main" {
  name                = "main-network"
  tags                = local.default_tags
  location            = azurerm_resource_group.current.location
  resource_group_name = azurerm_resource_group.current.name
  address_space       = var.vpc_address_space
}

resource "azurerm_network_security_group" "default" {
  name                = "main-network-security-group"
  location            = azurerm_resource_group.current.location
  resource_group_name = azurerm_resource_group.current.name
  tags                = local.default_tags

  security_rule {
    name                       = "AllowAll"
    description                = "Allow all"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowAllOut"
    description                = "Allow all"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

