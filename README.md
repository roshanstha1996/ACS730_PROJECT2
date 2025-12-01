# ACS730 Final Project - Two-Tier Web Application

This project deploys a highly available, auto-scaling two-tier web application on AWS using Terraform. The infrastructure includes a VPC with public/private subnets, Application Load Balancer, Auto Scaling Group, and bastion host across multiple availability zones.

## 🏗️ Architecture Overview

- **VPC**: Custom VPC with 3 public and 3 private subnets across 3 availability zones
- **Load Balancer**: Application Load Balancer distributing traffic across multiple EC2 instances
- **Auto Scaling**: Auto Scaling Group with CloudWatch-based scaling policies (CPU-based)
- **Compute**: EC2 instances in private subnets running Apache web server
- **Bastion Host**: Jump server in public subnet for SSH access to private instances
- **Storage**: S3 bucket with versioning and encryption for web content
- **Networking**: NAT Gateway for private subnet internet access, Internet Gateway for public access

## 📋 Prerequisites

- AWS Academy account with LabInstanceProfile
- Terraform >= 1.1.0
- AWS CLI configured
- SSH key pair (vockey) available in AWS
- **S3 Backend Bucket**: Create an S3 bucket named `project-acs730` in `us-east-1` for Terraform state storage
  - **OR** update the bucket name in `scripts/apply.sh` and `scripts/destroy.sh` (line 12)

## 🚀 Quick Start

### 1. Clone the Repository

```sh
git clone https://github.com/roshanstha1996/ACS730_PROJECT2.git
cd ACS730_PROJECT2
```

### 2. Create S3 Backend Bucket (First Time Only)

```sh
aws s3 mb s3://project-acs730 --region us-east-1
```

**⚠️ IMPORTANT:** If you use a different bucket name, update it in both scripts:

- `scripts/apply.sh` (line 12)
- `scripts/destroy.sh` (line 12)

### 3. Deploy Infrastructure

Use the provided scripts for automated deployment:

**Deploy Development Environment:**

````sh
**Deploy Development Environment:**

```sh
./scripts/apply.sh dev
````

**Deploy Staging Environment:**

```sh
./scripts/apply.sh staging
```

**Deploy Production Environment:**

```sh
./scripts/apply.sh prod
```

### 4. Access the Application

After deployment, Terraform will output the ALB DNS name:

```sh
# Example output
alb_dns_name = "dev-alb-75a27eaa-850892971.us-east-1.elb.amazonaws.com"
```

Visit `http://<alb_dns_name>` in your browser to see the application.

### 5. Destroy Infrastructure

**Destroy Development Environment:**

```sh
./scripts/destroy.sh dev
```

**Destroy Staging Environment:**

```sh
./scripts/destroy.sh staging
```

**Destroy Production Environment:**

```sh
./scripts/destroy.sh prod
```

## 🔧 Manual Deployment (Alternative)

If you prefer manual deployment:

1. **Initialize Terraform:**

   ```sh
   terraform init
   ```

2. **Plan Deployment:**

   ```sh
   terraform plan -var-file="envs/dev.tfvars"
   ```

3. **Apply Deployment:**
   ```sh
   terraform apply -var-file="envs/dev.tfvars"
   ```

## 📁 Project Structure

```
.
├── main.tf                      # Root module orchestrating all resources
├── variables.tf                 # Input variable definitions
├── outputs.tf                   # Output values
├── provider.tf                  # AWS provider configuration
├── envs/                        # Environment-specific configurations
│   ├── dev.tfvars              # Development environment
│   ├── staging.tfvars          # Staging environment
│   └── prod.tfvars             # Production environment
├── modules/
│   ├── network/                # VPC, subnets, route tables, NAT/IGW
│   ├── security/               # Security groups
│   ├── bastion/                # Bastion host
│   ├── launch_template/        # EC2 launch template with user-data
│   ├── asg/                    # Auto Scaling Group and policies
│   └── alb/                    # Application Load Balancer
├── scripts/
│   ├── apply.sh                # Automated deployment script
│   └── destroy.sh              # Automated destruction script
└── web/                        # Static web content
    ├── index.html
    └── images/
```

## 🌍 Environment Configuration

### Development (dev)

- Instance Type: `t3.micro`
- ASG: Min=1, Max=4, Desired=2
- VPC CIDR: `10.100.0.0/16`

### Staging (staging)

- Instance Type: `t3.small`
- ASG: Min=1, Max=4, Desired=3
- VPC CIDR: `10.200.0.0/16`

### Production (prod)

- Instance Type: `t3.medium`
- ASG: Min=2, Max=8, Desired=4
- VPC CIDR: `10.1.0.0/16`

## 🔒 Security Features

- **Private Instances**: Web servers in private subnets with no direct internet access
- **Security Groups**: Restrictive rules (ALB → Port 80, Bastion → Port 22)
- **S3 Encryption**: Server-side encryption with AES256
- **S3 Versioning**: Enabled for content recovery
- **Bastion Host**: Controlled SSH access point

## 📊 Auto Scaling Configuration

- **Scale Out**: When CPU > 70% for 4 minutes (adds 1 instance)
- **Scale In**: When CPU < 30% for 4 minutes (removes 1 instance)
- **Health Check Grace Period**: 15 minutes
- **Instance Warmup**: 20 minutes (prevents premature scaling)
- **Cooldown**: 60 seconds between scaling actions

## 🎯 Key Features

✅ Multi-AZ deployment for high availability  
✅ Environment-specific resource naming (dev-alb-xxx, staging-asg-xxx, etc.)  
✅ Automated S3 bucket creation and web content deployment  
✅ Optimized instance startup (< 3 minutes to healthy)  
✅ Health check monitoring with ALB target groups  
✅ CloudWatch alarms for automated scaling  
✅ Terraform state management with S3 backend

## 📝 Important Notes

- **AWS Academy Limitations**: Uses LabInstanceProfile (no custom IAM), AES256 encryption (no custom KMS)
- **NAT Gateway**: Single NAT Gateway to minimize costs (not HA in production)
- **State Files**: Separate state files per environment in S3 bucket `project-acs730`
- **Force Destroy**: Disabled for production S3 bucket, enabled for dev/staging

## 🐛 Troubleshooting

**Instances not becoming healthy?**

- Wait 15-20 minutes for health check grace period and warmup
- Check Security Group rules allow ALB → EC2 on port 80
- Verify NAT Gateway is running for S3 access

**Can't access ALB?**

- Ensure Security Group allows port 80 from 0.0.0.0/0
- Wait a few minutes after deployment for DNS propagation
- Check instances are in "healthy" state in target group

**Terraform state locked?**

- Another user/process is running Terraform
- Wait or force unlock: `terraform force-unlock <LOCK_ID>`

## 👥 Team Members

- Azamat Smailov
- Roshan Shrestha
- Dilip Dawadi
- Niroj Bagale
- Karson Rai

## 📄 License

This project is part of ACS730 course work.
