resource "cycloid_credential" "aws" {
  count = var.aws_sel ? 1 : 0

  name                   = "aws-dg"
  description            = "The AWS account for the DG."
  organization_canonical = cycloid_organization.org.canonical
  path                   = "aws-dg"
  canonical              = "aws-dg"

  type = "aws"
  body = {
    access_key = var.aws_cred_child.access_key
    secret_key = var.aws_cred_child.secret_key
  }
}

resource "cycloid_credential" "azure" {
  count = var.azure_sel ? 1 : 0

  name                   = "azure-dg"
  description            = "The Azure account for the DG."
  organization_canonical = cycloid_organization.org.canonical
  path                   = "azure-dg"
  canonical              = "azure-dg"

  type = "azure"
  body = {
    client_id = var.azure_cred_child.client_id
    client_secret = var.azure_cred_child.client_secret
    subscription_id = var.azure_cred_child.subscription_id
    tenant_id = var.azure_cred_child.tenant_id
  }
}