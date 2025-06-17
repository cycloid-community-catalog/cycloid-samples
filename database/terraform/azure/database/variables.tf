// Globals
variable "organization" { type = string }
variable "project" { type = string }
variable "environment" { type = string }
variable "component" { type = string }

# requirements
variable "resource_group_name" {
  type    = string
  default = ""
}

locals {
  resource_group_name = var.resource_group_name != "" ? var.resource_group_name : "${var.organization}-${var.project}-${var.environment}"
}

variable "virtual_network_name" {
  type = string
}

variable "engine_version" {
  type    = string
  default = "16"
}

variable "user" {
  type    = string
  default = "petclinic"
}

variable "password" {
  type      = string
  sensitive = true
  default   = "DatabaseCoucou80"
}

variable "sku" {
  type    = string
  default = "B_Standard_B1ms"
}

variable "database" {
  type    = string
  default = "petclinic"
}

variable "backup_retention_days" {
  type    = number
  default = 7
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
