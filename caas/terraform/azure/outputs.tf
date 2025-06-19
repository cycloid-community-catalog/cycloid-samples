output "application_url" {
  value = try(module.app.application_url, "")
}
