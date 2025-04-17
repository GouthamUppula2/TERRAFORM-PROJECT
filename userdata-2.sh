#!/bin/bash
apt update
apt install -y apache2

# Get the instance ID using the instance metadata
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

# Install the AWS CLI
apt install -y awscli

# Download the images from S3 bucket
#aws s3 cp s3://myterraformprojectbucket2023/project.webp /var/www/html/project.png --acl public-read

# Create a simple HTML file with the portfolio content and display the images
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Welcome to My Web App</title>
  <link rel="stylesheet" href="style.css" />
  <style>
  body {
  margin: 0;
  font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
  background: linear-gradient(to right, #f8f9fa, #e0f7fa);
  color: #333;
}

.container {
  text-align: center;
  padding: 100px 20px;
}

h1 {
  font-size: 3em;
  color: #007acc;
}

p {
  font-size: 1.2em;
  margin: 15px 0;
}

footer {
  margin-top: 50px;
  font-size: 0.9em;
  color: #777;
}

  </style>
</head>
<body>
  <div class="container">
    <h1> Welcome to My Web Application</h1>
    <p>This is a basic web page deployed on AWS using Terraform.</p>
    <p>You're viewing this through an Application Load Balancer.</p>
    <h2>Instance ID: <span style="color:navyblue">$INSTANCE_ID</span></h2>
    <footer>
      <p>© 2025 My Web App. All rights reserved.</p>
    </footer>
  </div>
</body>
</html>
EOF

# Start Apache and enable it on boot
systemctl start apache2
systemctl enable apache2