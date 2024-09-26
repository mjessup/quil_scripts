#!/bin/bash
# Define variables
REPO_URL="https://github.com/yourusername/your-repo.git"
SCRIPTS_DIR="/root/scripts"
ENV_FILE="$SCRIPTS_DIR/.storj_env"
CRONTAB_FILE="$SCRIPTS_DIR/crontab.txt"

# Install git if not installed
if ! command -v git &> /dev/null; then
    echo "Installing git..."
    sudo apt update && sudo apt install git -y
fi

# Clone or update the repo in /root/scripts
if [ -d "$SCRIPTS_DIR/.git" ]; then
    echo "Updating existing repository..."
    git -C "$SCRIPTS_DIR" pull
else
    echo "Cloning repository..."
    git clone "$REPO_URL" "$SCRIPTS_DIR"
fi

# Ensure .storj_env exists (but do not overwrite if it does)
if [ ! -f "$ENV_FILE" ]; then
    echo "Creating .storj_env file..."
    touch "$ENV_FILE"
    echo "# Add your satellite-address, api-key, and passphrase here" > "$ENV_FILE"
    echo "SATELLITE_ADDRESS='your-satellite-address'" >> "$ENV_FILE"
    echo "API_KEY='your-api-key'" >> "$ENV_FILE"
    echo "PASSPHRASE='your-passphrase'" >> "$ENV_FILE"
    echo "Remember to manually populate the .storj_env file with your sensitive data."
fi

# Set up crontab from the repo
if [ -f "$CRONTAB_FILE" ]; then
    echo "Applying crontab from $CRONTAB_FILE..."
    crontab "$CRONTAB_FILE"
else
    echo "Error: $CRONTAB_FILE not found."
    exit 1
fi

echo "Setup complete. Scripts and crontab are updated."
