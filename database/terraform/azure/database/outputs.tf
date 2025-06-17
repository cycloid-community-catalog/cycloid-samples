output "user" {
  value = var.db_user
}

output "database" {
  value = var.database
}

output "host" {
  value = azurerm_postgresql_flexible_server.db.fqdn
}

output "password" {
  value     = local.db_password
  sensitive = true
}
