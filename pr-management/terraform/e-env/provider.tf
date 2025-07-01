variable "organization" {}
variable "project" {}
variable "env" {}
variable "component" {}

# Terraform Amazon Web Services provider configuration
# See: https://registry.terraform.io/providers/hashicorp/aws/latest/docs
provider "aws" {
  access_key = var.aws_cred.access_key
  secret_key = var.aws_cred.secret_key
  region     = local.network_region

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

# This variable should be provided by the inventory (terraform output)
# Since it is not ready yet, we use the arn to define the cluster region and identifier
variable "network_inventory" {
  description = "Output from network that should container aws_cred+region+vpc_id"
}

locals {
  # "arn:aws:ec2:eu-west-1:11111111111:vpc/vpc-xxxx"
  # network_parts  = split(":", var.network_inventory)
  # network_region = local.network_parts[3]
  # network_vpc_id = split("/", local.network_parts[5])[1]

  network_region = "eu-west-1"
  network_vpc_id = var.network_inventory
}
