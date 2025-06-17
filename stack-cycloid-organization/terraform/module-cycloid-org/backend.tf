resource "cycloid_credential" "s3-cycloid" {
  name                   = "s3-cycloid"
  description            = "AWS IAM user credential allowing access to an S3 bucket used as Terraform backend for your Cycloid organization."
  organization_canonical = cycloid_organization.org.data.canonical
  path                   = "s3-cycloid"
  canonical              = "s3-cycloid"

  type = "aws"
  body = {
    access_key = var.cycloid_s3_access_key
    secret_key = var.cycloid_s3_secret_key
  }
}

resource "cycloid_external_backend" "tf_external_backend" {
  organization_canonical = cycloid_organization.org.data.canonical
  credential_canonical = cycloid_credential.s3-cycloid.canonical
  default = true
  purpose = "remote_tfstate"
  engine = "aws_storage"
  aws_storage = {
    bucket = "${var.dg_name}-terraform-remote-state"
    region = var.cycloid_s3_region
    endpoint = "https://s3.${var.cycloid_s3_region}.amazonaws.com"
    s3_force_path_style = false
    skip_verify_ssl = true
  }
}