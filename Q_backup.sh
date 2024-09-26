#!/bin/bash
# Set PATH explicitly
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Load environment variables from the .qnode_backup_env file
if [ -f "/root/scripts/.qnode_backup_env" ]; then
    source /root/scripts/.qnode_backup_env
else
    echo "Error: Environment file /root/scripts/.qnode_backup_env not found."
    exit 1
fi

# Install required packages
if ! command -v unzip &> /dev/null; then
    echo "Installing unzip..."
    sudo apt install unzip
fi

# Install uplink CLI if not already installed
if ! command -v uplink &> /dev/null; then
    echo "Installing uplink CLI..."
    curl -L https://github.com/storj/storj/releases/latest/download/uplink_linux_amd64.zip -o uplink_linux_amd64.zip
    unzip -o uplink_linux_amd64.zip
    sudo install uplink /usr/local/bin/uplink
    rm uplink_linux_amd64.zip
fi

# Storj setup (run only once)
if [ ! -f "/root/.local/share/storj/uplink/config.yaml" ]; then
    echo "Setting up uplink CLI..."
    uplink access create --import-as "main" --satellite-address "$SATELLITE_ADDRESS" --api-key "$API_KEY" --passphrase-stdin <<< "$PASSPHRASE" --force
fi

# Define variables
DIR_TO_BACKUP="/root/ceremonyclient/node/.config"
VPS_IP=$(hostname -I | awk '{print $1}')
STORJ_BUCKET="qnode-$VPS_IP"

# Check if the bucket already exists
if ! /usr/local/bin/uplink ls "sj://$STORJ_BUCKET" >/dev/null 2>&1; then
    # Bucket does not exist, create it
    echo "Creating a new bucket..."
    uplink mb "sj://$STORJ_BUCKET"
fi

# Define backup file name with date and time
BACKUP_FILE="backup__$(TZ='America/New_York' date +%m-%d-%Y__%a__%I-%M%p).tar.gz"

# Create a tar.gz file of the directory you want to backup and upload to Storj
echo "Creating tar file of $DIR_TO_BACKUP and uploading to Storj..."
tar -czf "/tmp/$BACKUP_FILE" -C "$(dirname "$DIR_TO_BACKUP")" "$(basename "$DIR_TO_BACKUP")"
uplink cp /tmp/$BACKUP_FILE sj://$STORJ_BUCKET/$BACKUP_FILE
echo "Backup script execution completed."

# Remove the backup file from /tmp
echo "Removing backup file from /tmp..."
rm -f "/tmp/$BACKUP_FILE"
echo "Backup script execution completed."
