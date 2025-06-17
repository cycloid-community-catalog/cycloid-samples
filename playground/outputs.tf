# App
output "app_url" {
  value = azurerm_container_app.app.latest_revision_fqdn
}

# DB
output "db" {
  value     = azurerm_postgresql_flexible_server.db
  sensitive = true
}

output "db_access" {
  value = {
    url      = azurerm_postgresql_flexible_server.db.fqdn
    db       = var.app_db
    user     = var.db_user
    password = local.db_password
  }
  sensitive = true
}

