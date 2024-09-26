#!/bin/bash

# Define colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Emojis
CHECK_MARK="✅"
ERROR_MARK="❌"
ARROW="➡️"
HOURGLASS="⏳"
DISK="💾"

# Define variables
REPO_URL="https://github.com/mjessup/quil_scripts.git"
SCRIPTS_DIR="/root/scripts"
ENV_FILE="$SCRIPTS_DIR/.storj_env"
CRONTAB_FILE="$SCRIPTS_DIR/crontab.txt"
CPU_PERFORMANCE_SETUP_URL="https://raw.githubusercontent.com/mjessup/CPU_Performance/main/setup.sh"

echo -e "${HOURGLASS} ${YELLOW}Starting Quil Scripts Setup...${NC}"

# Install git if not installed
if ! command -v git &> /dev/null; then
    echo -e "${ARROW} ${YELLOW}Git not found. Installing git...${NC}"
    sudo apt update && sudo apt install git -y
    echo -e "${CHECK_MARK} ${GREEN}Git installed successfully!${NC}"
else
    echo -e "${CHECK_MARK} ${GREEN}Git is already installed.${NC}"
fi

# Clone or update the repo in /root/scripts
if [ -d "$SCRIPTS_DIR/.git" ]; then
    echo -e "${ARROW} ${YELLOW}Repository already exists. Pulling latest changes...${NC}"
    git -C "$SCRIPTS_DIR" pull
    echo -e "${CHECK_MARK} ${GREEN}Repository updated successfully.${NC}"
else
    echo -e "${ARROW} ${YELLOW}Cloning repository...${NC}"
    git clone "$REPO_URL" "$SCRIPTS_DIR"
    echo -e "${CHECK_MARK} ${GREEN}Repository cloned successfully.${NC}"
fi

# Ensure .storj_env exists (but do not overwrite if it does)
if [ ! -f "$ENV_FILE" ]; then
    echo -e "${DISK} ${YELLOW}Creating .storj_env file...${NC}"
    touch "$ENV_FILE"
    echo "# Add your satellite-address, api-key, and passphrase here" > "$ENV_FILE"
    echo "SATELLITE_ADDRESS='your-satellite-address'" >> "$ENV_FILE"
    echo "API_KEY='your-api-key'" >> "$ENV_FILE"
    echo "PASSPHRASE='your-passphrase'" >> "$ENV_FILE"
    echo -e "${CHECK_MARK} ${GREEN}.storj_env created. Don't forget to manually fill in your sensitive data.${NC}"
else
    echo -e "${CHECK_MARK} ${GREEN}.storj_env file already exists. Skipping creation.${NC}"
fi

# Set up crontab from the repo
if [ -f "$CRONTAB_FILE" ]; then
    echo -e "${ARROW} ${YELLOW}Applying crontab from crontab.txt...${NC}"
    crontab "$CRONTAB_FILE"
    echo -e "${CHECK_MARK} ${GREEN}Crontab applied successfully.${NC}"
else
    echo -e "${ERROR_MARK} ${RED}Error: crontab.txt file not found!${NC}"
    exit 1
fi

# Install CPU performance script from external repo
echo -e "${HOURGLASS} ${YELLOW}Setting up CPU performance script from the external repository...${NC}"
if curl -s "$CPU_PERFORMANCE_SETUP_URL" | bash; then
    echo -e "${CHECK_MARK} ${GREEN}CPU performance script setup successfully.${NC}"
else
    echo -e "${ERROR_MARK} ${RED}Failed to set up CPU performance script.${NC}"
fi

echo -e "${CHECK_MARK} ${GREEN}Quil Scripts setup complete! All scripts and crontab are updated.${NC}"
