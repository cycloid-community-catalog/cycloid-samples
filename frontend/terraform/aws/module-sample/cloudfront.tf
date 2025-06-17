#
# App cloudfront
#

variable "lb_arn" {
  description = "ECS ALB ID"
}

data "aws_lb" "ecs" {
  arn = var.lb_arn
}

locals {
  alb_target_origin_id   = "ALB-${data.aws_lb.ecs.name}"
  alb_target_origin_name = data.aws_lb.ecs.dns_name
}

resource "aws_cloudfront_origin_access_identity" "spring" {
  comment = local.prefix_name
}

resource "aws_cloudfront_distribution" "cdn" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "${local.prefix_name} cdn on bucket"
  aliases         = []

  price_class = "PriceClass_200"

  custom_error_response {
    error_code            = 404
    error_caching_min_ttl = 0

    #response_code      = 200
    #response_page_path = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    # acm_certificate_arn      = var.cloudfront_ssl_certificate
    # ssl_support_method       = "sni-only"
    # minimum_protocol_version = "TLSv1"
  }

  origin {
    domain_name = local.alb_target_origin_name
    origin_id   = local.alb_target_origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2", "SSLv3"]
    }
  }

  # BUCKET
  origin {
    domain_name = aws_s3_bucket.spring.bucket_domain_name
    origin_id   = "origin-bucket-${aws_s3_bucket.spring.id}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.spring.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD", "DELETE", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = false

      #headers = ["*"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 300
    max_ttl                = 1200
    target_origin_id       = local.alb_target_origin_id
    viewer_protocol_policy = "allow-all"
    compress               = true
  }

  ordered_cache_behavior {
    allowed_methods = ["GET", "HEAD", "DELETE", "OPTIONS", "PATCH", "POST", "PUT"]

    path_pattern   = "/static/*"
    cached_methods = ["GET", "HEAD"]

    forwarded_values {
      query_string = false

      #headers = ["*"]

      cookies {
        forward = "none"
      }
    }

    min_ttl                = "0"
    default_ttl            = "300"
    max_ttl                = "1200"
    target_origin_id       = "origin-bucket-${aws_s3_bucket.spring.id}"
    viewer_protocol_policy = "allow-all"
    compress               = true
  }
}
