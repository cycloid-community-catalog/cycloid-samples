provider "aws" {
  access_key = var.aws_cred.access_key
  secret_key = var.aws_cred.secret_key
  region     = var.aws_region

  default_tags { # The default_tags block applies tags to all resources managed by this provider, except for the Auto Scaling groups (ASG).
    tags = {
      "cycloid.io" = "true"
      env          = var.cy_env
      project      = var.cy_project
      organization = var.cy_org
    }
  }
}

provider "cycloid" {
  url                    = var.cycloid_api_url
  jwt                    = var.cycloid_root_org_jwt
  organization_canonical = var.cy_org
}