resource "azurerm_subnet" "db" {
  name                 = "subnet-db"
  resource_group_name  = local.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = ["10.1.0.0/24"]
  # private_endpoint_network_policies             = "Disabled" # Disabled, Enabled, NetworkSecurityGroupEnabled or RouteTableEnabled
  # default_outbound_access_enabled               = true
  # private_link_service_network_policies_enabled = false
  service_endpoints = ["Microsoft.Sql", "Microsoft.Storage"] # Microsoft.AzureActiveDirectory, Microsoft.AzureCosmosDB, Microsoft.ContainerRegistry, Microsoft.EventHub, Microsoft.KeyVault, Microsoft.ServiceBus, Microsoft.Sql, Microsoft.Storage, Microsoft.Storage.Global and Microsoft.Web.
  delegation {
    name = "fs"

    service_delegation {
      # GitHub.Network/networkSettings, Informatica.DataManagement/organizations, Microsoft.ApiManagement/service, Microsoft.Apollo/npu, Microsoft.App/environments, Microsoft.App/testClients,
      # Microsoft.AVS/PrivateClouds, Microsoft.AzureCosmosDB/clusters, Microsoft.BareMetal/AzureHostedService, Microsoft.BareMetal/AzureHPC, Microsoft.BareMetal/AzurePaymentHSM, Microsoft.BareMetal/AzureVMware,
      # Microsoft.BareMetal/CrayServers, Microsoft.BareMetal/MonitoringServers, Microsoft.Batch/batchAccounts, Microsoft.CloudTest/hostedpools, Microsoft.CloudTest/images, Microsoft.CloudTest/pools, Microsoft.Codespaces/plans,
      # Microsoft.ContainerInstance/containerGroups, Microsoft.ContainerService/managedClusters, Microsoft.ContainerService/TestClients, Microsoft.Databricks/workspaces, Microsoft.DBforMySQL/flexibleServers, Microsoft.DBforMySQL/servers,
      # Microsoft.DBforMySQL/serversv2, Microsoft.DBforPostgreSQL/flexibleServers, Microsoft.DBforPostgreSQL/serversv2, Microsoft.DBforPostgreSQL/singleServers, Microsoft.DelegatedNetwork/controller, Microsoft.DevCenter/networkConnection, Microsoft.DevOpsInfrastructure/pools, Microsoft.DocumentDB/cassandraClusters, Microsoft.Fidalgo/networkSettings, Microsoft.HardwareSecurityModules/dedicatedHSMs, Microsoft.Kusto/clusters, Microsoft.LabServices/labplans, Microsoft.Logic/integrationServiceEnvironments, Microsoft.MachineLearningServices/workspaces, Microsoft.Netapp/volumes, Microsoft.Network/applicationGateways, Microsoft.Network/dnsResolvers, Microsoft.Network/managedResolvers, Microsoft.Network/fpgaNetworkInterfaces, Microsoft.Network/networkWatchers., Microsoft.Network/virtualNetworkGateways, Microsoft.Orbital/orbitalGateways, Microsoft.PowerAutomate/hostedRpa, Microsoft.PowerPlatform/enterprisePolicies, Microsoft.PowerPlatform/vnetaccesslinks, Microsoft.ServiceFabricMesh/networks, Microsoft.ServiceNetworking/trafficControllers, Microsoft.Singularity/accounts/networks, Microsoft.Singularity/accounts/npu, Microsoft.Sql/managedInstances, Microsoft.Sql/managedInstancesOnebox, Microsoft.Sql/managedInstancesStage, Microsoft.Sql/managedInstancesTest, Microsoft.Sql/servers, Microsoft.StoragePool/diskPools, Microsoft.StreamAnalytics/streamingJobs, Microsoft.Synapse/workspaces, Microsoft.Web/hostingEnvironments, Microsoft.Web/serverFarms, NGINX.NGINXPLUS/nginxDeployments, PaloAltoNetworks.Cloudngfw/firewalls, Qumulo.Storage/fileSystems, and Oracle.Database/networkAttachments.
      name = "Microsoft.DBforPostgreSQL/flexibleServers"
      # Microsoft.Network/networkinterfaces/*, Microsoft.Network/publicIPAddresses/join/action, Microsoft.Network/publicIPAddresses/read, Microsoft.Network/virtualNetworks/read, Microsoft.Network/virtualNetworks/subnets/action, Microsoft.Network/virtualNetworks/subnets/join/action, Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action, and Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action.
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "db" {
  network_security_group_id = data.azurerm_network_security_group.main.id
  subnet_id                 = azurerm_subnet.db.id
}

resource "azurerm_private_dns_zone" "db" {
  name                = "${local.prefix.kebab}.private.postgres.database.azure.com"
  tags                = local.default_tags
  resource_group_name = local.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "db" {
  name                  = "zone-db-link"
  tags                  = local.default_tags
  private_dns_zone_name = azurerm_private_dns_zone.db.name
  virtual_network_id    = data.azurerm_virtual_network.main.id
  resource_group_name   = local.resource_group_name
  registration_enabled  = true
  depends_on            = [azurerm_subnet.db]
}

resource "random_password" "password" {
  length = 64
}

locals {
  db_password = var.password == "" ? random_password.password.result : var.password
}

resource "azurerm_postgresql_flexible_server" "db" {
  name                          = "postgres-${var.project}-${var.environment}"
  tags                          = local.default_tags
  resource_group_name           = local.resource_group_name
  location                      = data.azurerm_resource_group.current.location
  version                       = var.engine_version
  delegated_subnet_id           = azurerm_subnet.db.id
  private_dns_zone_id           = azurerm_private_dns_zone.db.id
  public_network_access_enabled = false
  administrator_login           = var.user
  administrator_password        = local.db_password
  sku_name                      = var.sku
  storage_mb                    = 32768
  storage_tier                  = "P4"
  depends_on                    = [azurerm_private_dns_zone_virtual_network_link.db]
  lifecycle {
    ignore_changes = [zone]
  }
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "network" {
  name             = "allow-main-subnet"
  server_id        = azurerm_postgresql_flexible_server.db.id
  start_ip_address = cidrhost("10.0.0.0/8", 1)
  end_ip_address   = cidrhost("10.0.0.0/8", -2)
}

resource "azurerm_postgresql_flexible_server_database" "app" {
  name      = var.database
  server_id = azurerm_postgresql_flexible_server.db.id
  collation = "en_US.utf8"
  charset   = "UTF8"

  # prevent the possibility of accidental data loss
  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_postgresql_flexible_server_configuration" "no_ssl" {
  # Disable TLS for demo
  server_id = azurerm_postgresql_flexible_server.db.id
  name      = "require_secure_transport"
  value     = "off"
}
