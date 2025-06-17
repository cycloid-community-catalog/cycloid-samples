output "resource_group_name" {
  value = azurerm_resource_group.current.name
}

output "resource_group" {
  value = azurerm_resource_group.current
}

output "network_prefix" {
  value = var.vpc_address_space
}
