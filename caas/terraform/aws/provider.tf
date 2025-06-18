variable "organization" {}
variable "project" {}
variable "env" {}
variable "component" {}

# Terraform Amazon Web Services provider configuration
# See: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
provider "aws" {
  access_key = var.aws_cred.access_key
  secret_key = var.aws_cred.secret_key
  region     = local.database_region

  default_tags { # The default_tags block applies tags to all resources managed by this provider, except for the Auto Scaling groups (ASG).
    tags = {
      "cycloid.io"    = "true"
      cy_component    = var.component
      cy_env          = var.env
      cy_project      = var.project
      cy_organization = var.organization
      # extra digit tags
      Organization = "digit"
      Project      = var.organization
      Environment  = var.env
    }
  }
}

variable "aws_cred" {} # { access_key, secret_key }

# This variable should be provided by the inventory (terraform output)
# Since it is not ready yet, we use the arn to define the cluster region and identifier
variable "database_inventory" {
  description = "Output from database that should container aws_cred+region+cluster_identifier"
}

locals {
  # "arn:aws:rds:eu-west-1:111111111111:cluster:digit-dev-xxxx"
  database_cluster_parts      = split(":", var.database_inventory)
  database_region             = local.database_cluster_parts[3]
  database_cluster_identifier = local.database_cluster_parts[6]
}

# variable "aws_region" {
#   description = "AWS region to launch servers."
#   default     = "eu-west-1"
# }

variable "web_image" {}
variable "web_image_digest" {}
variable "web_image_version" {}
