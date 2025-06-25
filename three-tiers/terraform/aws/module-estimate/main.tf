variable "engine_version" {
  default = "16"
}

variable "postgres_type" {
  default = "db.t3.medium"
}

variable "project" {
  default = "project"
}
variable "env" {
  default = "env"
}
variable "component" {
  default = "component"
}
variable "organization" {
  default = "organization"
}

variable "aws_region" {}


module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.project}-${var.env}-${var.component}"

  cidr                = "10.0.0.0/16"
  private_subnets     = ["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"]
  private_subnet_tags = { "role" = "private" }

  public_subnets     = ["10.0.96.0/19", "10.0.128.0/19", "10.0.160.0/19"]
  public_subnet_tags = { "role" = "public" }

  database_subnets     = ["10.0.192.0/24", "10.0.193.0/24", "10.0.194.0/24"]
  database_subnet_tags = { "role" = "database" }

  # elasticache_subnets = ["10.0.195.0/24", "10.0.196.0/24", "10.0.197.0/24"]
  # elasticache_subnet_tags = { "role" = "elasticache"}

  # usefull to expose publicly rds replicate
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = true

  azs = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
}

#database
module "database" {
  source       = "github.com/cycloid-community-catalog/cycloid-samples/database/terraform/aws/module-sample?ref=stacks"
  component    = var.component
  env          = var.env
  project      = var.project
  organization = var.organization

  aws_region = var.aws_region
  vpc_id     = "foobar"

  postgres_engine_version = var.engine_version
  postgres_type           = var.postgres_type
}
