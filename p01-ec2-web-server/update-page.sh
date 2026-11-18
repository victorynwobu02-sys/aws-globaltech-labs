
#!/bin/bash

# Exit immediately if a command fails.
set -e

# Define the EC2 Instance Metadata Service (IMDS) endpoint.
IMDS="http://169.254.169.254/latest"

# Request an IMDSv2 token for secure metadata access.
TOKEN=$(curl -sS -X PUT "$IMDS/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

# Set the token header for all metadata requests.
HEADER="X-aws-ec2-metadata-token: $TOKEN"

# Retrieve the EC2 instance ID.
INSTANCE_ID=$(curl -sS -H "$HEADER" "$IMDS/meta-data/instance-id")

# Retrieve the EC2 instance type.
INSTANCE_TYPE=$(curl -sS -H "$HEADER" "$IMDS/meta-data/instance-type")

# Retrieve the AWS region.
REGION=$(curl -sS -H "$HEADER" "$IMDS/meta-data/placement/region")

# Retrieve the availability zone.
AVAILABILITY_ZONE=$(curl -sS -H "$HEADER" "$IMDS/meta-data/placement/availability-zone")

# Retrieve the public IPv4 address.
PUBLIC_IP=$(curl -sS -H "$HEADER" "$IMDS/meta-data/public-ipv4")

# Get the current date and time of the page update.
UPDATE_TIME=$(date '+%Y-%m-%d %H:%M:%S')

# Rebuild the Globaltech website index page with the retrieved metadata.
sudo tee /var/www/html/index.html > /dev/null <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Globaltech EC2 Information</title>
</head>
<body>
    <h1>Welcome to Globaltech</h1>

    <p>Welcome to Globaltech! We are pleased to have you here.
    This page displays information about our running AWS EC2 instance.</p>

    <h2>EC2 Instance Information</h2>

    <table border="1" cellpadding="10">
        <tr>
            <th>Metadata</th>
            <th>Value</th>
        </tr>
        <tr>
            <td>Instance ID</td>
            <td>$INSTANCE_ID</td>
        </tr>
        <tr>
            <td>Instance Type</td>
            <td>$INSTANCE_TYPE</td>
        </tr>
        <tr>
            <td>Region</td>
            <td>$REGION</td>
        </tr>
        <tr>
            <td>Availability Zone</td>
            <td>$AVAILABILITY_ZONE</td>
        </tr>
        <tr>
            <td>Public IPv4</td>
            <td>$PUBLIC_IP</td>
        </tr>
    </table>

    <p>Last Updated: $UPDATE_TIME</p>
</body>
</html>
EOF

# Display a success message after rebuilding the page.
echo "Globaltech website updated successfully!"
echo "Updated at: $UPDATE_TIME"
