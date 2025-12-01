module "network" {
  source      = "./modules/network"
  environment = var.environment
  vpc_cidr    = var.vpc_cidr
}

module "bastion" {
  source        = "./modules/bastion"
  environment   = var.environment
  vpc_cidr      = var.vpc_cidr
  vpc_id        = module.network.vpc_id
  public_subnet = module.network.public_subnets[0]
  key_name      = var.key_name
  bastion_sg_id = module.security.bastion_sg_id
  my_ip         = var.my_ip
}

module "security" {
  source        = "./modules/security"
  vpc_id        = module.network.vpc_id
  bastion_sg_id = module.bastion.bastion_sg_id
  environment   = var.environment
}

module "alb" {
  source         = "./modules/alb"
  vpc_id         = module.network.vpc_id
  public_subnets = module.network.public_subnets
  alb_sg_id      = module.security.alb_sg_id
  ec2_sg_id      = module.security.ec2_sg_id
  environment    = var.environment
}




module "launch_template" {
  source        = "./modules/launch_template"
  environment   = var.environment
  web_bucket    = aws_s3_bucket.web.id
  ec2_sg_id     = module.security.ec2_sg_id
  instance_type = var.instance_type
}

module "asg" {
  source               = "./modules/asg"
  launch_template_id   = module.launch_template.launch_template_id
  private_subnets      = module.network.private_subnets
  desired_capacity     = var.instance_count
  min_size             = 1
  max_size             = 4
  alb_target_group_arn = module.alb.target_group_arn
  environment          = var.environment
}

# We need the S3 bucket resource defined here so we can pass its ID to the module
resource "aws_s3_bucket" "web" {
  bucket_prefix = "acs730-project-${var.environment}-"
  force_destroy = var.environment != "prod" ? true : false

  tags = {
    Name        = "${var.environment}-web-content"
    Environment = var.environment
    Project     = "ACS730-FinalProject"
    ManagedBy   = "Terraform"
    Purpose     = "WebContent"
  }
}

resource "aws_s3_bucket_versioning" "web" {
  bucket = aws_s3_bucket.web.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Using AES256 (AWS managed encryption) instead of KMS Customer Managed Keys
# because AWS Academy environments don't provide permissions to create/manage KMS keys.
# AES256 provides server-side encryption that is sufficient for this project.
# tfsec:ignore:aws-s3-encryption-customer-key
resource "aws_s3_bucket_server_side_encryption_configuration" "web" {
  bucket = aws_s3_bucket.web.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.web.id
  key          = "index.html"
  source       = "${path.module}/web/index.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/web/index.html")
}

resource "aws_s3_object" "image" {
  bucket       = aws_s3_bucket.web.id
  key          = "images/sample.jpg"
  source       = "${path.module}/web/images/sample.jpg"
  content_type = "image/jpeg"
}
  