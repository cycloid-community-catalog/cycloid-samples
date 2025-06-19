resource "cycloid_credential" "apikey" {
  name                   = "admin-api-key"
  description            = "The Cycloid API key."
  organization_canonical = cycloid_organization.org.canonical
  path                   = "admin-api-key"
  canonical              = "admin-api-key"

  type = "basic_auth"
  body = {
    username = "admin"
    password = var.cycloid_root_org_jwt
  }
}