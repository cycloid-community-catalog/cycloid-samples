resource "cycloid_credential" "apikey" {
  count = var.azure_sel ? 1 : 0

  name                   = "admin_api_key"
  description            = "The Cycloid API key."
  organization_canonical = cycloid_organization.org.canonical
  path                   = "admin_api_key"
  canonical              = "admin_api_key"

  type = "basic_auth"
  body = {
    username = "admin"
    password = var.cycloid_root_org_jwt
  }
}