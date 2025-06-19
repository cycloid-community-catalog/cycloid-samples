output "application_url" {
  value = try(module.spring.spring_url, "")
}
