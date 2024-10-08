#!/bin/bash

# Define colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Emojis
CHECK_MARK="✅"
ERROR_MARK="❌"
HOURGLASS="⏳"
DISK="💾"

# Define the GitHub repository and branch
REPO_URL="https://raw.githubusercontent.com/mjessup/quil_scripts/main"

# List of files to download from the GitHub repository
FILES=("setup.sh" "crontab.txt" "Q_backup.sh" "change_hostname.sh" "setup_custom_nodes.sh" "stop_node_script.py")

echo -e "${HOURGLASS} ${YELLOW}Starting Quil Scripts Setup...${NC}"

# Ensure the scripts directory exists
SCRIPTS_DIR="/root/scripts"
mkdir -p "$SCRIPTS_DIR"

# Download each file from the repository
for file in "${FILES[@]}"; do
    echo -e "${DISK} ${YELLOW}Downloading $file...${NC}"
    curl -s "$REPO_URL/$file" -o "$SCRIPTS_DIR/$file"
    if [ $? -eq 0 ]; then
        echo -e "${CHECK_MARK} ${GREEN}$file downloaded successfully.${NC}"
    else
        echo -e "${ERROR_MARK} ${RED}Failed to download $file.${NC}"
    fi
done

# Set executable permissions for the scripts that require them
echo -e "${HOURGLASS} ${YELLOW}Setting executable permissions for scripts...${NC}"
chmod +x "$SCRIPTS_DIR/setup.sh" "$SCRIPTS_DIR/Q_backup.sh" "$SCRIPTS_DIR/change_hostname.sh" "$SCRIPTS_DIR/setup_custom_nodes.sh" "$SCRIPTS_DIR/stop_node_script.py"

if [ $? -eq 0 ]; then
    echo -e "${CHECK_MARK} ${GREEN}Permissions set successfully.${NC}"
else
    echo -e "${ERROR_MARK} ${RED}Failed to set permissions.${NC}"
fi

# Ensure .storj_env exists (but do not overwrite if it does)
ENV_FILE="$SCRIPTS_DIR/.storj_env"
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

# Install CPU performance script from external repo
CPU_PERFORMANCE_SETUP_URL="https://raw.githubusercontent.com/mjessup/CPU_Performance/main/setup.sh"
echo -e "${HOURGLASS} ${YELLOW}Setting up CPU performance script from the external repository...${NC}"
if curl -s "$CPU_PERFORMANCE_SETUP_URL" | bash; then
    echo -e "${CHECK_MARK} ${GREEN}CPU performance script setup successfully.${NC}"
else
    echo -e "${ERROR_MARK} ${RED}Failed to set up CPU performance script.${NC}"
fi

# Crontab setup (this will run last to prevent conflicts)
CRONTAB_FILE="$SCRIPTS_DIR/crontab.txt"
EXISTING_CRONTAB=$(mktemp)

echo -e "${HOURGLASS} ${YELLOW}Checking existing crontab and merging changes...${NC}"

# Capture the existing crontab into a temporary file
crontab -l > "$EXISTING_CRONTAB" 2>/dev/null

# Merge the crontab while preserving comments and removing duplicates
MERGED_CRONTAB=$(mktemp)

# Copy the contents of crontab.txt, ensuring no duplicates and maintaining order
while IFS= read -r new_line; do
    # If the line is a comment or an empty line, preserve it
    if [[ -z "$new_line" || "$new_line" =~ ^# ]]; then
        echo "$new_line" >> "$MERGED_CRONTAB"
        continue
    fi

    # Check if the line is already in the existing crontab to avoid duplicates
    if ! grep -Fxq "$new_line" "$EXISTING_CRONTAB"; then
        echo "$new_line" >> "$MERGED_CRONTAB"
    fi
done < "$CRONTAB_FILE"

# Now append any remaining cron jobs from the existing crontab that aren't duplicates
while IFS= read -r existing_line; do
    # Skip lines that already exist in the merged crontab to avoid duplication
    if ! grep -Fxq "$existing_line" "$MERGED_CRONTAB"; then
        echo "$existing_line" >> "$MERGED_CRONTAB"
    fi
done < "$EXISTING_CRONTAB"

# Apply the final merged crontab
crontab "$MERGED_CRONTAB"
rm "$EXISTING_CRONTAB" "$MERGED_CRONTAB"

echo -e "${CHECK_MARK} ${GREEN}Crontab merged and applied successfully, preserving comments and avoiding duplicates.${NC}"

echo -e "${CHECK_MARK} ${GREEN}Quil Scripts setup complete! All scripts and crontab are updated.${NC}"
