####################
# Postgres         #
####################

# Allow container to access postgres
resource "aws_security_group_rule" "ecs_web_to_postgres" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs_web.id
  security_group_id        = local.database_security_group_id
}
