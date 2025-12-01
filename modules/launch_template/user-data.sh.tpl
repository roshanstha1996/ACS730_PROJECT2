#!/bin/bash
yum update -y
yum install -y httpd aws-cli
systemctl enable httpd
systemctl start httpd

# Get instance metadata
instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id || echo "unknown")

cd /var/www/html
aws s3 cp s3://${bucket_name}/index.html . 2>/dev/null || echo "<h1>Welcome to ${environment}</h1>" > index.html
aws s3 cp s3://${bucket_name}/images/ ./images/ --recursive 2>/dev/null || mkdir -p images

# Add environment and instance info
echo "<p style='background:#999;padding:10px;margin-bottom:10px;border-radius:20px;width:300px'>Environment: ${environment}</p>" >> index.html
echo "<p style='background:#999;padding:10px;margin-bottom:10px;border-radius:20px;width:300px'>Instance ID: $instance_id</p>" >> index.html

chown -R apache:apache /var/www/html