# Cycloid
variable "cy_org" {}
variable "cy_project" {}
variable "cy_env" {}
variable "cy_component" {}

variable "dg_name" {
  description = "The name of the DG."
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

variable "cycloid_git_url" {
  description = "Git repository URL for stacks and config."
  default = "trials"
}

variable "cycloid_git_ssh_key" {
  description = "Git repository SSH key for stacks and config."
  default = ""
  sensitive = true
}

variable "cycloid_s3_access_key" {
  description = "S3 bucket access_key for Terraform state files."
  default = ""
}

variable "cycloid_s3_secret_key" {
  description = "S3 bucket secret_key for Terraform state files."
  default = ""
  sensitive = true
}

variable "cycloid_s3_region" {
  description = "S3 bucket region for Terraform state files."
  default = "eu-west-1"
}

variable "private_key_openssh" {
  description = "SSH Key Pair used in newly provisionned workloads."
  default = ""
  sensitive = true
}

variable "cycloid_root_org_jwt" {
  type        = string
  description = "Root Org JWT used for authentication"
  sensitive   = true
}

variable "mailjet_api_key" {
  type        = string
  description = "Mailjet API key"
  sensitive   = true
}

variable "mailjet_secret_key" {
  type        = string
  description = "Mailjet secret key"
  sensitive   = true
}
