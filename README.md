# ACS730 Final Project
first
```sh
cd acs730-final-project
 ```

This project contains Terraform code to deploy a web application on AWS using ASG and ALB.

Copy your static site to an S3 bucket

Create an S3 bucket for each environment for index.html and /images

Upload contents of web/ to the S3 bucket via AWS Console or CLI:

```sh
aws s3 mb s3://mygroup-dev-bucket   #REPLACE YOUR BUCKET
aws s3 cp web/index.html s3://mygroup-dev-bucket/index.html #REPLACE YOUR BUCKET
aws s3 cp web/images/ s3://mygroup-dev-bucket/images/ --recursive #REPLACE YOUR BUCKET
```

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
