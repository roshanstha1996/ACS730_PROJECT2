#!/usr/bin/env bash
set -euo pipefail

# Usage: ./scripts/destroy-dev.sh [env]
ENV=${1:-dev}
TFVARS="envs/${ENV}.tfvars"

terraform init \
  -backend-config="bucket=project-acs730" \
  -backend-config="key=${ENV}/terraform.tfstate" \
  -backend-config="region=us-east-1" \
  -reconfigure

terraform fmt -recursive
terraform validate

PLAN_FILE="${ENV}.destroy.plan"
terraform plan -destroy -var-file="${TFVARS}" -out="${PLAN_FILE}"
terraform apply -auto-approve "${PLAN_FILE}"
rm -f "${PLAN_FILE}"