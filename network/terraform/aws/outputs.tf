output "vpc_id" {
  value = try(module.vpc.vpc_id, "")
}

output "public_subnets" {
  value = try(module.vpc.public_subnets, "")
}

output "private_subnets" {
  value = try(module.vpc.private_subnets, "")
}

output "database_subnet_group_name" {
  value = try(module.vpc.database_subnet_group_name, "")
}

output "aws_region" {
  value = try(var.aws_region, "")
}
