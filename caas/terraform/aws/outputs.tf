output "alb_url" {
  value = try(module.spring.spring_url, "")
}
