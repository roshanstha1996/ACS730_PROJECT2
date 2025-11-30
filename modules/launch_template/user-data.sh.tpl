#!/bin/bash
# Lightweight user-data: install httpd fast, start it, serve a fallback page
# then install aws-cli and update site content asynchronously so ALB health
# checks can pass quickly while S3 sync happens in background.

yum install -y httpd || true
systemctl enable httpd
systemctl start httpd
cd /var/www/html
instance_id=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

# Immediate fallback page so the web server responds 200 quickly
cat > /var/www/html/index.html <<EOF
<html><body>
<p style='background:#222;padding:10px;margin-bottom:10px;border-radius:20px;width:300px'>Environment: ${environment}</p>
<p style='background:#222;padding:10px;margin-bottom:10px;border-radius:20px;width:300px'>Instance ID: $${instance_id}</p>
</body></html>
EOF

chown apache:apache /var/www/html -R

# In background: install aws-cli and try to overwrite index.html with S3 content
(
	yum install -y aws-cli || true
	if aws s3 cp "s3://${bucket_name}/index.html" /var/www/html/index.html.tmp; then
		echo "<p style='background:#222;padding:10px;margin-bottom:10px;border-radius:20px;width:300px'>Environment: ${environment}</p>" >> /var/www/html/index.html.tmp
		echo "<p style='background:#222;padding:10px;margin-bottom:10px;border-radius:20px;width:300px'>Instance ID: $${instance_id}</p>" >> /var/www/html/index.html.tmp
		mv /var/www/html/index.html.tmp /var/www/html/index.html
	fi
	aws s3 cp s3://${bucket_name}/images/ ./images/ --recursive || mkdir images || true
	chown apache:apache /var/www/html -R
) &