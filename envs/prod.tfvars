environment    = "prod"
aws_region     = "us-east-1"
vpc_cidr       = "10.250.0.0/16"
instance_count = 3
instance_type  = "t3.medium"
key_name       = "vockey"
# SECURITY: Restrict to specific IP address for production
my_ip          = "0.0.0.0/0"  # TODO: Change this to your actual IP!