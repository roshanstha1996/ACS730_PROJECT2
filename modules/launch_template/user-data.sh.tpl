#!/bin/bash
set -x  # Enable debug logging
exec > >(tee /var/log/user-data.log) 2>&1

# Install and start httpd immediately
yum update -y
yum install -y httpd
systemctl enable httpd
systemctl start httpd

# Wait for httpd to be fully started
sleep 5
systemctl status httpd

# Get instance metadata
instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id || echo "unknown")

# Create immediate fallback page
cat > /var/www/html/index.html <<'EOF'
<html><body>
<p style='background:#999;padding:10px;margin-bottom:10px;border-radius:20px;width:300px'>Environment: ${environment}</p>
<p style='background:#999;padding:10px;margin-bottom:10px;border-radius:20px;width:300px'>Instance ID: INSTANCE_ID_PLACEHOLDER</p>
</body></html>
EOF

# Replace placeholder with actual instance ID
sed -i "s/INSTANCE_ID_PLACEHOLDER/$instance_id/g" /var/www/html/index.html

# Set proper permissions
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

# Restart httpd to ensure it picks up the content
systemctl restart httpd

# In background: install aws-cli and update site content
(
	sleep 10
	yum install -y aws-cli
	
	# Try to get content from S3
	if aws s3 cp "s3://${bucket_name}/index.html" /var/www/html/index.html.tmp 2>/dev/null; then
		echo "<p style='background:#999;padding:10px;margin-bottom:10px;border-radius:20px;width:300px'>Environment: ${environment}</p>" >> /var/www/html/index.html.tmp
		echo "<p style='background:#999;padding:10px;margin-bottom:10px;border-radius:20px;width:300px'>Instance ID: $instance_id</p>" >> /var/www/html/index.html.tmp
		mv /var/www/html/index.html.tmp /var/www/html/index.html
	fi
	
	# Get images from S3
	mkdir -p /var/www/html/images
	aws s3 cp s3://${bucket_name}/images/ /var/www/html/images/ --recursive 2>/dev/null || true
	
	chown -R apache:apache /var/www/html
	systemctl restart httpd
) &

echo "User data script completed at $(date)" >> /var/log/user-data.log