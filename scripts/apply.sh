#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/apply-dev.sh [env]
# Example: ./scripts/apply-dev.sh dev
ENV=${1:-dev}
TFVARS="envs/${ENV}.tfvars"

# Initialize backend for the chosen env (adjust backend key if you use different names)
terraform init \
  -backend-config="bucket=project-acs730" \
  -backend-config="key=${ENV}/terraform.tfstate" \
  -backend-config="region=us-east-1" \
  -reconfigure

terraform fmt -recursive
terraform validate

PLAN_FILE="${ENV}.plan"
terraform plan -var-file="${TFVARS}" -out="${PLAN_FILE}"
terraform apply -auto-approve "${PLAN_FILE}"
rm -f "${PLAN_FILE}"