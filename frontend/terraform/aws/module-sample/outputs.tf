output "cloudfront_url" {
  value = try(aws_cloudfront_distribution.cdn.domain_name, "")
}
