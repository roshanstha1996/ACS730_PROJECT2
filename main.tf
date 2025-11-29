module "network" {
  source               = "./modules/network"
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
}

module "security" {
  source       = "./modules/security"
  vpc_id       = module.network.vpc_id
}

module "alb" {
  source               = "./modules/alb"
  vpc_id               = module.network.vpc_id
  public_subnets       = module.network.public_subnets
  alb_sg_id            = module.security.alb_sg_id
  ec2_sg_id            = module.security.ec2_sg_id
}

module "launch_template" {
  source            = "./modules/launch_template"
  environment       = var.environment
  web_bucket        = aws_s3_bucket.web.id
  ec2_sg_id         = module.security.ec2_sg_id
  instance_type     = var.instance_type
  # REMOVED the invalid user_data_file line here
}

module "asg" {
  source                = "./modules/asg"
  launch_template_id    = module.launch_template.launch_template_id
  public_subnets        = module.network.public_subnets
  desired_capacity      = var.instance_count
  min_size              = 1
  max_size              = 4
  alb_target_group_arn  = module.alb.target_group_arn
}

# We need the S3 bucket resource defined here so we can pass its ID to the module
resource "aws_s3_bucket" "web" {
  bucket_prefix = "acs730-project-${var.environment}-"
  force_destroy = true
}
