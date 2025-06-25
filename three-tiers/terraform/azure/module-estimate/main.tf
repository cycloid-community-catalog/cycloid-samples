variable "engine_version" {
  default = "16"
}

variable "sku" {
  default = "B_Standard_B2s"
}

variable "project" {
  default = "project"
}
variable "env" {
  default = "env"
}
variable "component" {
  default = "component"
}
variable "organization" {
  default = "organization"
}

# network
module "network" {
  source       = "github.com/cycloid-community-catalog/cycloid-samples/database/terraform/azure/network"
  component    = var.component
  env          = var.env
  project      = var.project
  organization = var.organization

  resource_group_name = "${var.organization}-${var.project}-${var.env}"
}

#database
module "database" {
  source       = "github.com/cycloid-community-catalog/cycloid-samples/database/terraform/azure/database"
  component    = var.component
  env          = var.env
  project      = var.project
  organization = var.organization
  sku          = var.sku
}

module "caas" {
  source       = "github.com/cycloid-community-catalog/cycloid-samples/caas/terraform/azure/app"
  component    = var.component
  env          = var.env
  project      = var.project
  organization = var.organization

  app_image = "${var.web_image}:${local.image_tag}"
  db_name   = "postgres-${var.project}-${var.env}"
}
