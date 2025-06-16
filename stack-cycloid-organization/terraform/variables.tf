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

variable "aws_sel" {
  description = "Shall we provision an AWS account in the new DG."
}

variable "aws_cred_child" {
  description = "Contains AWS access_key and secret_key"
  sensitive   = true
}

variable "azure_sel" {
  description = "Shall we provision an AWS account in the new DG."
}

variable "azure_cred_child" {
  description = "Contains Azure credentials."
  sensitive   = true
}
variable "cycloid_root_org_jwt" {
  type        = string
  description = "Root Org JWT used for authentication"
  sensitive   = true
}

variable "cycloid_api_url" {
  type        = string
  default     = "https://api.cycloid.io/"
  description = "Cycloid API endpoint"
}

variable "github_pat" {
  type        = string
  description = "GitHub Personal Access Token"
  sensitive   = true
}