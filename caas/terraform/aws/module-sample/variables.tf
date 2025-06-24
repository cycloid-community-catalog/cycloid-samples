variable "organization" {}
variable "project" {}
variable "env" {}
variable "component" {}

variable "aws_region" {}
variable "database_cluster_identifier" {}

# Get VPC and Network informations

# Get DB from database_cluster_identifier
# data "aws_rds_cluster" "database" {
#   cluster_identifier = var.database_cluster_identifier
# }

# Get VPC from database security group
data "aws_security_group" "database" {
  # get the first sg to know which vpc is used
  # id = local.database_security_group_id
  filter {
    name   = "tag:Name"
    values = [var.database_cluster_identifier]
  }
}

# Get subnets from vpc and roel tag
data "aws_subnets" "private" {
  # https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeSubnets.html
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }

  tags = {
    role = "private"
  }
}
data "aws_subnets" "public" {
  # https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_DescribeSubnets.html
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }

  tags = {
    role = "public"
  }
}

locals {
  # database_security_group_id = one(data.aws_rds_cluster.database.vpc_security_group_ids)
  database_security_group_id = data.aws_security_group.database.id
  vpc_id                     = data.aws_security_group.database.vpc_id
  public_subnets             = data.aws_subnets.public.ids
  private_subnets            = data.aws_subnets.private.ids
}

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
