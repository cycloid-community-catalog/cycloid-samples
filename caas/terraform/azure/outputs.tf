output "application_url" {
  value = try(module.app.frontdoor_url, "")
}
