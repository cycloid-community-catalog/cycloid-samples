data "aws_route_table" "private_route_tables" {
  count     = length(local.private_subnets)
  subnet_id = local.private_subnets[count.index]
}

resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id            = local.vpc_id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  auto_accept       = true
  route_table_ids   = [for rt in data.aws_route_table.private_route_tables : rt.id]
}
