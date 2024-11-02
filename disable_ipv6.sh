#!/bin/bash

# Step 1: Disable IPv6 in sysctl.conf
echo "Disabling IPv6 in /etc/sysctl.conf..."
echo -e "\n# Disable IPv6\nnet.ipv6.conf.all.disable_ipv6 = 1\nnet.ipv6.conf.default.disable_ipv6 = 1\nnet.ipv6.conf.lo.disable_ipv6 = 1" | sudo tee -a /etc/sysctl.conf

# Step 2: Apply sysctl changes
echo "Applying sysctl changes..."
sudo sysctl -p

# Step 3: Create a version-detecting rc.local file
echo "Creating /etc/rc.local with version detection..."

sudo tee /etc/rc.local > /dev/null << 'EOF'
#!/bin/bash

# Detect Ubuntu version and apply appropriate commands
VERSION=$(lsb_release -rs)

if [[ "$VERSION" == "22.04" ]]; then
    # For Ubuntu 22.04
    /etc/sysctl.d
    /etc/init.d/procps restart
elif [[ "$VERSION" == "24.04" ]]; then
    # For Ubuntu 24.04
    /sbin/sysctl -p /etc/sysctl.conf
    /etc/init.d/procps restart
else
    echo "Unsupported Ubuntu version: $VERSION"
    exit 1
fi

exit 0
EOF

# Step 4: Make rc.local executable
echo "Making /etc/rc.local executable..."
sudo chmod 755 /etc/rc.local

# Step 5: Prompt for reboot
echo "IPv6 has been disabled. A reboot is recommended to apply all changes."
