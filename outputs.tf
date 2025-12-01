output "active_environment" {
  description = "The environment variable value used for this run (from -var-file or TF_VAR_environment)."
  value       = var.environment
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.alb.dns_name
}

output "bastion_public_ip" {
  description = "Public IP address of the Bastion host"
  value       = module.bastion.bastion_ip
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.network.vpc_id
}

output "s3_bucket_name" {
  description = "S3 bucket name for web content"
  value       = aws_s3_bucket.web.id
}

