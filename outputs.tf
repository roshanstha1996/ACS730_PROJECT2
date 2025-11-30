output "active_environment" {
  description = "The environment variable value used for this run (from -var-file or TF_VAR_environment)."
  value       = var.environment
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.dns_name
}

