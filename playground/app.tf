resource "azurerm_log_analytics_workspace" "app" {
  name                = "logs-${local.app_name}"
  tags                = local.default_tags
  location            = azurerm_resource_group.current.location
  resource_group_name = azurerm_resource_group.current.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "app" {
  name                               = "container-app-env-${local.app_name}"
  resource_group_name                = azurerm_resource_group.current.name
  location                           = azurerm_resource_group.current.location
  tags                               = local.default_tags
  logs_destination                   = "log-analytics"
  log_analytics_workspace_id         = azurerm_log_analytics_workspace.app.id
  infrastructure_subnet_id           = azurerm_subnet.app.id
  infrastructure_resource_group_name = "${azurerm_resource_group.current.name}-managed-env"
  internal_load_balancer_enabled     = true
  zone_redundancy_enabled            = false
  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
    maximum_count         = 0
    minimum_count         = 0
  }
}

resource "azurerm_storage_account" "app" {
  name                     = "fsappnametamer"
  tags                     = local.default_tags
  resource_group_name      = azurerm_resource_group.current.name
  location                 = azurerm_resource_group.current.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "app" {
  name               = "share-${local.app_name}"
  storage_account_id = azurerm_storage_account.app.id
  quota              = 5
}

resource "azurerm_container_app_environment_storage" "app" {
  name                         = "storage-${local.app_name}"
  container_app_environment_id = azurerm_container_app_environment.app.id
  account_name                 = azurerm_storage_account.app.name
  access_key                   = azurerm_storage_account.app.primary_access_key
  share_name                   = azurerm_storage_share.app.name
  access_mode                  = "ReadWrite"
}

locals {
  app_name  = var.app_name != "" ? var.app_name : var.component
  app_image = "${var.app_image}:${var.app_tag}"

  # temp remove after split
  pgurl = "jdbc:postgresql://${azurerm_postgresql_flexible_server.db.fqdn}:5432/${var.app_db}"
}

resource "azurerm_container_app" "app" {
  name                         = "app-${local.app_name}"
  tags                         = local.default_tags
  container_app_environment_id = azurerm_container_app_environment.app.id
  resource_group_name          = azurerm_resource_group.current.name
  revision_mode                = "Single"
  workload_profile_name        = "Consumption"
  max_inactive_revisions       = 1

  ingress {
    allow_insecure_connections = false
    client_certificate_mode    = "ignore" # ["accept" "require" "ignore"]
    external_enabled           = true
    target_port                = var.app_port
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  secret {
    name  = "pgurl"
    value = local.pgurl
  }

  dynamic "secret" {
    for_each = var.app_secrets
    content {
      name  = replace(lower(secret.key), "_", "-")
      value = secret.value
    }
  }

  template {
    min_replicas                     = var.app_min_replicas
    max_replicas                     = var.app_max_replicas
    termination_grace_period_seconds = 5

    container {
      name   = local.app_name
      image  = local.app_image
      cpu    = var.app_resources.cpu
      memory = var.app_resources.memory

      env {
        name        = "POSTGRES_URL"
        secret_name = "pgurl"
      }

      dynamic "env" {
        for_each = var.app_env
        content {
          name  = env.key
          value = env.value
        }
      }

      dynamic "env" {
        for_each = var.app_secrets
        content {
          name        = env.key
          secret_name = replace(lower(env.key), "_", "-")
        }
      }
    }
  }
}
