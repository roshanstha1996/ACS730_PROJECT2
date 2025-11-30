#!/usr/bin/env bash
set -euo pipefail
ENV=${1:-dev}
TFVARS="envs/${ENV}.tfvars"

# Initialize backend for dev and apply changes non-interactively
terraform init \
  -backend-config="bucket=project-acs730" \
  -backend-config="key=${ENV}/terraform.tfstate" \
  -backend-config="region=us-east-1" \
  -reconfigure

terraform fmt -recursive
terraform validate

terraform plan -var-file="${TFVARS}" -var="key_name=vockey" -var='my_ip=0.0.0.0/0' -out=${ENV}.plan
terraform apply -auto-approve ${ENV}.plan
rm -f ${ENV}.plan