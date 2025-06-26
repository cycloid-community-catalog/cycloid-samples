resource "azurerm_subnet" "app" {
  name                 = "subnet-app"
  resource_group_name  = data.azurerm_resource_group.current.name
  virtual_network_name = data.azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.0.0/20"]
  service_endpoints    = [] # Microsoft.AzureActiveDirectory, Microsoft.AzureCosmosDB, Microsoft.ContainerRegistry, Microsoft.EventHub, Microsoft.KeyVault, Microsoft.ServiceBus, Microsoft.Sql, Microsoft.Storage, Microsoft.Storage.Global and Microsoft.Web.
  delegation {
    name = "containerAppDelegation"

    service_delegation {
      name = "Microsoft.App/environments" # GitHub.Network/networkSettings, Informatica.DataManagement/organizations, Microsoft.ApiManagement/service, Microsoft.Apollo/npu, Microsoft.App/environments, Microsoft.App/testClients, Microsoft.AVS/PrivateClouds, Microsoft.AzureCosmosDB/clusters, Microsoft.BareMetal/AzureHostedService, Microsoft.BareMetal/AzureHPC, Microsoft.BareMetal/AzurePaymentHSM, Microsoft.BareMetal/AzureVMware, Microsoft.BareMetal/CrayServers, Microsoft.BareMetal/MonitoringServers, Microsoft.Batch/batchAccounts, Microsoft.CloudTest/hostedpools, Microsoft.CloudTest/images, Microsoft.CloudTest/pools, Microsoft.Codespaces/plans, Microsoft.ContainerInstance/containerGroups, Microsoft.ContainerService/managedClusters, Microsoft.ContainerService/TestClients, Microsoft.Databricks/workspaces, Microsoft.DBforMySQL/flexibleServers, Microsoft.DBforMySQL/servers, Microsoft.DBforMySQL/serversv2, Microsoft.DBforPostgreSQL/flexibleServers, Microsoft.DBforPostgreSQL/serversv2, Microsoft.DBforPostgreSQL/singleServers, Microsoft.DelegatedNetwork/controller, Microsoft.DevCenter/networkConnection, Microsoft.DevOpsInfrastructure/pools, Microsoft.DocumentDB/cassandraClusters, Microsoft.Fidalgo/networkSettings, Microsoft.HardwareSecurityModules/dedicatedHSMs, Microsoft.Kusto/clusters, Microsoft.LabServices/labplans, Microsoft.Logic/integrationServiceEnvironments, Microsoft.MachineLearningServices/workspaces, Microsoft.Netapp/volumes, Microsoft.Network/applicationGateways, Microsoft.Network/dnsResolvers, Microsoft.Network/managedResolvers, Microsoft.Network/fpgaNetworkInterfaces, Microsoft.Network/networkWatchers., Microsoft.Network/virtualNetworkGateways, Microsoft.Orbital/orbitalGateways, Microsoft.PowerAutomate/hostedRpa, Microsoft.PowerPlatform/enterprisePolicies, Microsoft.PowerPlatform/vnetaccesslinks, Microsoft.ServiceFabricMesh/networks, Microsoft.ServiceNetworking/trafficControllers, Microsoft.Singularity/accounts/networks, Microsoft.Singularity/accounts/npu, Microsoft.Sql/managedInstances, Microsoft.Sql/managedInstancesOnebox, Microsoft.Sql/managedInstancesStage, Microsoft.Sql/managedInstancesTest, Microsoft.Sql/servers, Microsoft.StoragePool/diskPools, Microsoft.StreamAnalytics/streamingJobs, Microsoft.Synapse/workspaces, Microsoft.Web/hostingEnvironments, Microsoft.Web/serverFarms, NGINX.NGINXPLUS/nginxDeployments, PaloAltoNetworks.Cloudngfw/firewalls, Qumulo.Storage/fileSystems, and Oracle.Database/networkAttachments.
      # Microsoft.Network/networkinterfaces/*, Microsoft.Network/publicIPAddresses/join/action, Microsoft.Network/publicIPAddresses/read, Microsoft.Network/virtualNetworks/read, Microsoft.Network/virtualNetworks/subnets/action, Microsoft.Network/virtualNetworks/subnets/join/action, Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action, and Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action.
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_log_analytics_workspace" "app" {
  name                = "logs-${local.app_name}"
  tags                = local.default_tags
  location            = data.azurerm_resource_group.current.location
  resource_group_name = data.azurerm_resource_group.current.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "app" {
  name                               = "container-app-env-${local.app_name}"
  resource_group_name                = data.azurerm_resource_group.current.name
  location                           = data.azurerm_resource_group.current.location
  tags                               = local.default_tags
  logs_destination                   = "log-analytics"
  log_analytics_workspace_id         = azurerm_log_analytics_workspace.app.id
  infrastructure_subnet_id           = azurerm_subnet.app.id
  infrastructure_resource_group_name = "${data.azurerm_resource_group.current.name}-managed-env"
  internal_load_balancer_enabled     = true
  zone_redundancy_enabled            = false
  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
    maximum_count         = 0
    minimum_count         = 0
  }
}

resource "random_password" "storage_account_name" {
  length  = 12
  lower   = true
  upper   = false
  special = false
  numeric = false
}

resource "azurerm_storage_account" "app" {
  name                     = random_password.storage_account_name.result
  tags                     = local.default_tags
  resource_group_name      = data.azurerm_resource_group.current.name
  location                 = data.azurerm_resource_group.current.location
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
  app_name  = var.app_name != "" ? var.app_name : "${var.project}-${var.component}"
  app_image = var.app_image

  # temp remove after split
  pgurl = "jdbc:postgresql://${data.azurerm_postgresql_flexible_server.db.fqdn}:5432/${var.app_db}"
}

resource "azurerm_container_app" "app" {
  name                         = "app-${local.app_name}"
  tags                         = local.default_tags
  container_app_environment_id = azurerm_container_app_environment.app.id
  resource_group_name          = data.azurerm_resource_group.current.name
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
