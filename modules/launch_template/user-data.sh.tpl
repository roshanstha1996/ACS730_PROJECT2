#!/bin/bash
yum update -y
yum install -y httpd aws-cli
systemctl enable httpd
systemctl start httpd
cd /var/www/html
aws s3 cp s3://${bucket_name}/index.html .
aws s3 cp s3://${bucket_name}/images/ ./images/ --recursive || mkdir images || true
chown apache:apache /var/www/html -R
