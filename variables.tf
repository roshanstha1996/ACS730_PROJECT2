variable "environment" {
  type        = string
  description = "Deployment environment: dev, staging or prod"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod"
  }
}
variable "vpc_cidr" { type = string }

variable "key_name" {
  type = string
}

variable "my_ip" {
  type = string
}
variable "instance_count" { type = number }
variable "instance_type" { type = string }
