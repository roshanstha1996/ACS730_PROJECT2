provider "aws" {
  region = "ca-central-1" # Change if needed
  # Credentials are auto-picked up by AWS Academy/Cloud9 (use profile if needed)
}

terraform {
  required_version = ">= 1.1.0"
  backend "s3" {
    # S3 bucket and key will be set per environment
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
