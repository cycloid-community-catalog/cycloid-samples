output "cloudfront_url" {
  value = try(module.frontend.cloudfront_url, "")
}
