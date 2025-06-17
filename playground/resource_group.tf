resource "azurerm_resource_group" "current" {
  name     = local.prefix.kebab
  location = var.location
  tags     = local.default_tags
}
