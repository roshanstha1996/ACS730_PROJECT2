terraform {
  required_version = ">= 1.1.0"

  backend "s3" {
    # Backend values provided during terraform init
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

