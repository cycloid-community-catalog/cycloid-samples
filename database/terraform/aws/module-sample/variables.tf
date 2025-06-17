variable "organization" {}
variable "project" {}
variable "env" {}
variable "component" {}

variable "aws_region" {}
variable "vpc_id" {}

#Used to only keep few char for component like ALB name
variable "nameregex" {
  default = "/[^0-9A-Za-z-]/"
  type    = string
}

# Random string used to have different name if default it too long
resource "random_string" "name" {
  length  = 10
  upper   = false
  special = false
}

locals {
  # default_short_uniqname is 22 chars max
  default_short_uniqname = replace("${substr(var.project, 0, 5)}-${substr(var.env, 0, 5)}-${random_string.name.result}", var.nameregex, "-")
  default_uniqname       = replace("${local.prefix_name}", var.nameregex, "-")
  # Not 32 because we add suffix on DB name such "_uploader" so we keep 10 less
  uniqname = length(local.default_uniqname) > 25 ? local.default_short_uniqname : local.default_uniqname

  prefix_name = "${var.project}-${var.env}-${var.component}"
}
