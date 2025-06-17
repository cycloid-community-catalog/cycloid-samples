variable "organization" {}
variable "project" {}
variable "env" {}
variable "component" {}

# Terraform Amazon Web Services provider configuration
# See: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
provider "aws" {
  access_key = var.aws_cred.access_key
  secret_key = var.aws_cred.secret_key
  region     = local.ecs_region

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

# variable "aws_region" {
#   description = "AWS region to launch servers."
#   default     = "eu-west-1"
# }


variable "ecs_inventory" {
  description = "Output from network that should container aws_cred+region+vpc_id"
}

locals {
  # arn:aws:elasticloadbalancing:eu-west-1:1111111111:loadbalancer/app/digit-dev-spring/xxxxxxxxxx
  ecs_parts  = split(":", var.ecs_inventory)
  ecs_region = local.ecs_parts[3]
  ecs_lb_arn = var.ecs_inventory
}

