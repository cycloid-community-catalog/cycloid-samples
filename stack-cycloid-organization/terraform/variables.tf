# Cycloid variables
variable "cy_org" {}
variable "cy_project" {}
variable "cy_env" {}
variable "cy_component" {}

variable "dg_name" {
  description = "The name of the DG."
}

# AWS variables
variable "aws_cred" {
  description = "Contains AWS access_key and secret_key"
  sensitive   = true
}
variable "aws_region" {
  description = "AWS region where to create servers."
  default     = "eu-west-1"
}

variable "cycloid_api_url" {
  type        = string
  default     = "https://api.cycloid.io/"
  description = "Cycloid API endpoint"
}

variable "cycloid_root_org_canonical" {
  type        = string
  description = "Cycloid Root Organization Canonical"
}

variable "cycloid_root_org_jwt" {
  type        = string
  description = "Root Org JWT used for authentication"
  sensitive   = true
}

variable "github_pat" {
  type        = string
  description = "GitHub Personal Access Token"
  sensitive   = true
}