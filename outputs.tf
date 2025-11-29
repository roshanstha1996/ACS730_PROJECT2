output "alb_dns" {
  value = module.alb.dns_name
  description = "ALB DNS endpoint"
}
