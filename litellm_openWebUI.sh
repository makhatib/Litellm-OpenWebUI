#!/bin/bash
# Enhanced installation script for litellm and open-webui

# Exit immediately if a command fails
set -e

#######################################
# Function: Check required commands
#######################################
function check_command() {
  command -v "$1" >/dev/null 2>&1 || { echo >&2 "$1 is not installed. Exiting."; exit 1; }
}

check_command git
check_command docker
check_command docker-compose

echo "All required commands are installed."

#######################################
# Configuration defaults
#######################################
# litellm is set to run on port 4000 (as defined in its docker-compose file)
LITELLM_HOST_PORT=4000
# open-webui defaults
OPEN_WEBUI_DEFAULT_HOST_PORT=3000
OPEN_WEBUI_DEFAULT_MOUNT="/app/backend/data"

#######################################
# Install and configure litellm
#######################################
echo "=== Installing and configuring litellm application ==="

# Clone or update the litellm repository
if [ -d "litellm" ]; then
  echo "Directory 'litellm' already exists. Pulling latest changes..."
  cd litellm
  git pull
  cd ..
else
  git clone https://github.com/BerriAI/litellm.git
fi

# Change into litellm directory
cd litellm

# Collect sensitive keys from the user
echo "Please provide the following details for the .env configuration:"
read -p "Enter LITELLM_MASTER_KEY suffix (without 'sk-'): " master_input
read -p "Enter LITELLM_SALT_KEY suffix (without 'sk-'): " salt_input

# Prepend the required "sk-" prefix
LITELLM_MASTER_KEY="sk-$master_input"
LITELLM_SALT_KEY="sk-$salt_input"

echo ""
echo "Creating .env file with the following content:"
echo "LITELLM_MASTER_KEY=$LITELLM_MASTER_KEY"
echo "LITELLM_SALT_KEY=$LITELLM_SALT_KEY"
echo ""

# Write the .env file
cat <<EOF > .env
LITELLM_MASTER_KEY=$LITELLM_MASTER_KEY
LITELLM_SALT_KEY=$LITELLM_SALT_KEY
EOF

echo "Please copy the above .env file content to your notes if needed."
read -p "Press Enter to continue and start the litellm application..."

# Start the litellm application using docker-compose
docker-compose up -d

# Return to the parent directory
cd ..

#######################################
# Install and configure open-webui
#######################################
echo "=== Installing and configuring open web UI application ==="

# Clone or update the open-webui repository
if [ -d "open-webui" ]; then
  echo "Directory 'open-webui' already exists. Pulling latest changes..."
  cd open-webui
  git pull
  cd ..
else
  git clone https://github.com/open-webui/open-webui.git
fi

# Prompt user for custom volume mount (if desired)
read -p "Enter custom volume mount path for open-webui (or press Enter to use default '$OPEN_WEBUI_DEFAULT_MOUNT'): " custom_mount
if [ -z "$custom_mount" ]; then
  mount_point="$OPEN_WEBUI_DEFAULT_MOUNT"
else
  mount_point="$custom_mount"
fi

# Prompt user for a custom host port for open-webui
read -p "Enter host port for open-webui (default: $OPEN_WEBUI_DEFAULT_HOST_PORT): " open_webui_host_port
if [ -z "$open_webui_host_port" ]; then
  open_webui_host_port=$OPEN_WEBUI_DEFAULT_HOST_PORT
fi

# Run the open-webui container with the specified configuration
docker run -d -p $open_webui_host_port:8080 -v open-webui:"$mount_point" --name open-webui --restart always ghcr.io/open-webui/open-webui:main

#######################################
# Display access URLs and status
#######################################
# Retrieve the machine's IP address (the first IP from hostname -I)
machine_ip=$(hostname -I | awk '{print $1}')

echo ""
echo "Installation complete."
echo "Access your applications at the following URLs:"
echo "litellm: http://$machine_ip:$LITELLM_HOST_PORT/"
echo "open web ui: http://$machine_ip:$open_webui_host_port/"

echo ""
echo "Current running docker containers:"
docker ps
