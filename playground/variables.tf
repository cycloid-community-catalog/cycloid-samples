// Globals
variable "organization" { type = string }
variable "project" { type = string }
variable "environment" { type = string }
variable "component" { type = string }

variable "location" {
  type    = string
  default = "West Europe"
}

variable "vpc_address_space" {
  type    = list(string)
  default = ["10.0.0.0/8"]
}

# variable "subnets" {
#   type = map(object({
#     prefixes          = optional(list(string), ["10.0.0.0/24"])
#     service_endpoints = optional(list(string), [])
#   }))
#   default = {
#     app = {
#       prefixes          = ["10.0.0.0/24"]
#       service_endpoints = []
#     }
#   }
# }
#
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

# DB
variable "db_version" {
  type    = string
  default = "16"
}

variable "db_user" {
  type    = string
  default = "petclinic"
}

variable "db_password" {
  type      = string
  sensitive = true
  default   = "DatabaseCoucou80"
}

variable "db_sku" {
  type    = string
  default = "B_Standard_B1ms"
}

# app
variable "app_name" {
  type    = string
  default = ""
}

variable "app_image" {
  type    = string
  default = "cycloid/spring-framework-petclinic"
}

variable "app_tag" {
  type    = string
  default = "latest"
}

variable "app_resources" {
  type = object({
    cpu    = number
    memory = string
  })
  # [cpu: 0.25, memory: 0.5Gi]; [cpu: 0.5, memory: 1.0Gi]; [cpu: 0.75, memory: 1.5Gi]; [cpu: 1.0, memory: 2.0Gi];
  # [cpu: 1.25, memory: 2.5Gi]; [cpu: 1.5, memory: 3.0Gi]; [cpu: 1.75, memory: 3.5Gi]; [cpu: 2.0, memory: 4.0Gi];
  # [cpu: 2.25, memory: 4.5Gi]; [cpu: 2.5, memory: 5.0Gi]; [cpu: 2.75, memory: 5.5Gi]; [cpu: 3, memory: 6.0Gi];
  # [cpu: 3.25, memory: 6.5Gi]; [cpu: 3.5, memory: 7Gi]; [cpu: 3.75, memory: 7.5Gi]; [cpu: 4, memory: 8Gi]
  default = {
    cpu    = 0.5
    memory = "1Gi"
  }
}

variable "app_port" {
  type    = number
  default = 8080
}

variable "app_env" {
  type = map(string)
  default = {
    "SPRING_PROFILES_ACTIVE" = "postgres"
  }
}

variable "app_secrets" {
  type      = map(string)
  sensitive = true
  default = {
    "POSTGRES_USER" = "petclinic"
    "POSTGRES_PASS" = "DatabaseCoucou80"
    # "PGADMIN_DEFAULT_EMAIL"    = "admin@cycloid.io"
    # "PGADMIN_DEFAULT_PASSWORD" = "cycloidio"
    # "PGADMIN_LISTEN_PORT"      = "8080"
  }
}

variable "app_db" {
  type    = string
  default = "petclinic"
}

variable "app_min_replicas" {
  type    = number
  default = 1
}

variable "app_max_replicas" {
  type    = number
  default = 1
}
