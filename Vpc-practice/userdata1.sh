#!/bin/bash

# Variables
BUCKET_NAME="my-terraform-bucket"  # Replace with your S3 bucket name
FILE_KEY="data.txt"                # Replace with your S3 object key
LOCAL_FILE="/var/www/html/data.txt" # Path to save the file

# Update system and install necessary tools
yum update -y
yum install -y httpd aws-cli

# Start Apache web server
systemctl start httpd
systemctl enable httpd

# Fetch file from S3
aws s3 cp "s3://vishalsuthar-terraform-practice-bucket-2004/data.txt" /var/www/html/data.txt

# Create a simple HTML file to display the S3 file content
cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head><title>S3 Data Viewer</title></head>
<body>
<h1>Web Server 2 Data from S3:</h1>
<h2>$(cat /var/www/html/data.txt)</h2>
</body>
</html>
EOF

echo "Setup complete! Visit your EC2 instance's public IP to see the S3 data."
