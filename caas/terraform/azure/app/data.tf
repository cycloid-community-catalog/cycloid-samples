locals {
  resource_group_name = "${var.organization}-${var.project}-${var.environment}"
}

data "azurerm_virtual_network" "main" {
  name                = "main-network"
  resource_group_name = local.resource_group_name
}

data "azurerm_postgresql_flexible_server" "db" {
  name                = local.db_name
  resource_group_name = local.resource_group_name
}

locals {
  db_name = var.db_name != "" ? var.db_name : "postgres-${var.project}-${var.environment}"
}

data "azurerm_resource_group" "current" {
  name = local.resource_group_name
}
