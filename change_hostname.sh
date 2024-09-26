#!/bin/bash

# Prompt for new hostname
read -p "Enter the new hostname: " NEW_HOSTNAME

# Set the new hostname
sudo hostnamectl set-hostname "$NEW_HOSTNAME"

# Update /etc/hosts file
sudo bash -c "cat > /etc/hosts <<EOF
127.0.0.1       localhost
127.0.1.1       $NEW_HOSTNAME
EOF"

# Update /etc/hostname file
echo "$NEW_HOSTNAME" | sudo tee /etc/hostname

# Inform the user
echo "Hostname has been updated to $NEW_HOSTNAME"
echo "Please reboot your system to apply the changes."

# Prompt for reboot
read -p "Do you want to reboot now? (y/n): " REBOOT_CHOICE
if [[ "$REBOOT_CHOICE" =~ ^[Yy]$ ]]; then
    sudo reboot
fi
