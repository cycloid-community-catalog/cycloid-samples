resource "cycloid_credential" "apikey" {
  count = var.azure_sel ? 1 : 0

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

resource "cycloid_credential" "mailjet" {
  name                   = "mailjet"
  description            = "The Mailjet key."
  organization_canonical = cycloid_organization.org.canonical
  path                   = "mailjet"
  canonical              = "mailjet"

  type = "basic_auth"
  body = {
    username = var.mailjet_api_key
    password = var.mailjet_secret_key
  }
}