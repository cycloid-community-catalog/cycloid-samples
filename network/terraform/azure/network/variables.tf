// Globals
variable "organization" { type = string }
variable "project" { type = string }
variable "environment" { type = string }
variable "component" { type = string }

# requirements
variable "resource_group_name" {
  type = string
}

variable "location" {
  type    = string
  default = "West Europe"
}

variable "vpc_address_space" {
  type    = list(string)
  default = ["10.0.0.0/8"]
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
    cy_stack        = "network"
    managed_by      = "cycloid"
  }
}
