variable "hosted_zone" {
  default     = "demo.cycloid.io"
  description = "route 53 hosted zone"
}

data "aws_route53_zone" "hosted_zone" {
  name = var.hosted_zone
}

resource "aws_route53_record" "spring" {
  name    = local.prefix_name
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  type    = "A"
  alias {
    name                   = aws_alb.ecs.dns_name
    zone_id                = aws_alb.ecs.zone_id
    evaluate_target_health = true
  }
}

resource "aws_acm_certificate" "spring" {
  domain_name       = "${local.prefix_name}.${var.hosted_zone}"
  validation_method = "DNS"

  tags = {
    Name = "${local.prefix_name}-spring"
    role = "ecs"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# TODO: https://linear.app/cycloid/issue/PROD-370/unable-to-estimate-cost
locals {
  aws_acm_certificate = {
    for dvo in aws_acm_certificate.spring.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
}

resource "aws_route53_record" "spring-validation" {
  for_each = local.aws_acm_certificate
  # for_each = {
  #   for dvo in aws_acm_certificate.spring.domain_validation_options : dvo.domain_name => {
  #     name   = dvo.resource_record_name
  #     record = dvo.resource_record_value
  #     type   = dvo.resource_record_type
  #   }
  # }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.hosted_zone.zone_id
}

resource "aws_acm_certificate_validation" "spring-validation" {
  certificate_arn         = aws_acm_certificate.spring.arn
  validation_record_fqdns = [for record in aws_route53_record.spring-validation : record.fqdn]
}

###########
# Outputs #
###########

output "spring_url" {
  value = aws_route53_record.spring.fqdn
}
