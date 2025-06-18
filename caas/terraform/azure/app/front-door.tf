locals {
  app_name = var.component
}
resource "azurerm_cdn_frontdoor_profile" "app" {
  name                = "front-door-${local.app_name}"
  resource_group_name = data.azurerm_resource_group.current.name
  sku_name            = "Premium_AzureFrontDoor"
  tags                = local.default_tags
}


resource "azurerm_cdn_frontdoor_endpoint" "https" {
  name                     = "https-${local.app_name}"
  tags                     = local.default_tags
  enabled                  = true
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.app.id
}



resource "azurerm_cdn_frontdoor_origin_group" "app" {
  name                     = "app-origin-group-${local.app_name}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.app.id
  session_affinity_enabled = true

  load_balancing {
    additional_latency_in_milliseconds = 0
    sample_size                        = 16
    successful_samples_required        = 3
  }

}

resource "azurerm_cdn_frontdoor_origin" "app" {
  name                           = "app-origin-${local.app_name}"
  enabled                        = true
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.app.id
  certificate_name_check_enabled = true
  host_name                      = azurerm_container_app.app.ingress[0].fqdn
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = azurerm_container_app.app.ingress[0].fqdn
  priority                       = 1
  weight                         = 1

  # Cannot create pprivate_link programmaticaly with our subscription
  # private_link {
  #   location               = data.azurerm_resource_group.current.location
  #   private_link_target_id = azurerm_container_app.app.id
  #   target_type            = "managedEnvironments"
  #   request_message        = "Automated AFK private link request"
  # }

  lifecycle {
    ignore_changes = [private_link]
  }
}

resource "azurerm_cdn_frontdoor_route" "default" {
  name                          = "route-${local.app_name}"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.https.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.app.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.app.id]
  supported_protocols           = ["Http", "Https"]
  patterns_to_match             = ["/*"]
  forwarding_protocol           = "HttpsOnly"
  link_to_default_domain        = true
  https_redirect_enabled        = true
}
