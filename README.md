# ACS730 Final Project

This project contains Terraform code to deploy a web application on AWS using ASG and ALB.

## Deployment Instructions

1. Initialize Terraform:
   ```sh
   terraform init \
    -backend-config="bucket=help2223" \
    -backend-config="key=dev/terraform.tfstate" \
    -backend-config="region=us-east-1"
   ```

2. Plan the deployment (e.g., for dev environment):
   ```sh
   terraform plan -var-file="envs/dev.tfvars"
   ```

3. Apply the deployment:
   ```sh
   terraform apply -var-file="envs/dev.tfvars"
   ```

## Credits
- Azamat Smailov
- Member 2
- Member 3
- Member 4
