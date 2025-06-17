# Cycloid variables defined in ../provider.tf. And passed through ../main.tf.sample
# usually used to properly tag cloud provider resources
variable "component" {}
variable "environment" {}
variable "project" {}
variable "organization" {}

variable "container_app_name" {
  type = string
}

locals {
  prefix_list = [var.project, var.environment, var.component]
  prefix = {
    kebab     = join("-", local.prefix_list)
    snake     = join("_", local.prefix_list)
    camel     = replace(title(join(" ", local.prefix_list)), " ", "")
    lowercase = replace(join("", local.prefix_list), "-", "")
  }
  default_tags = {
    cy_organization = var.organization
    cy_project      = var.project
    cy_environment  = var.environment
    cy_component    = var.component
    cy_stack        = "spring"
    managed_by      = "cycloid"
  }
}
