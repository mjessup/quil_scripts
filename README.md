```markdown
# Quil Scripts Repository

This repository contains various scripts and configuration files for managing and deploying crypto nodes across multiple servers. The primary goal of this repo is to provide a simple and automated way to deploy, update, and maintain servers using these scripts.

## Purpose

1. **Deploy New Servers**: Easily set up new servers by running the `setup.sh` script, which will:
   - Download and place all necessary scripts in the `/root/scripts` directory.
   - Set up crontab entries to automate specific tasks.
   - Ensure environment variables for sensitive data are properly managed through a `.storj_env` file (to be manually populated on each server).

2. **Update Existing Servers**: If changes are made to any scripts in the repository (including the crontab), simply run `setup.sh` again on the server to pull the latest updates from GitHub. This process ensures all servers are using the latest versions of your scripts without manual intervention.

## How to Use

### 1. Setting Up a New Server

- Clone this repository and run the `setup.sh` script on your new server:
  
```bash
git clone https://github.com/mjessup/quil_scripts.git /root/scripts
cd /root/scripts
bash setup.sh
```

- This script will:
  - Clone or update the repository.
  - Ensure the required scripts are placed in `/root/scripts`.
  - Set up the correct crontab entries from `crontab.txt`.
  - Create a `.storj_env` file (which you'll need to populate manually with sensitive data such as your satellite address, API key, and passphrase).

### 2. Updating an Existing Server

- To update the scripts or crontab on an existing server, simply re-run the `setup.sh` script:
  
```bash
cd /root/scripts
bash setup.sh
```

- This will pull the latest changes from the GitHub repository and apply any updates to your scripts and crontab.

## Managing Sensitive Data

Sensitive data like your StorJ satellite address, API key, and passphrase are stored in a `.storj_env` file. This file should not be added to GitHub to avoid exposing sensitive information.

- After running `setup.sh` for the first time, a placeholder `.storj_env` file will be created at `/root/scripts/.storj_env`. 
- You must manually populate it with your credentials as follows:

```bash
SATELLITE_ADDRESS="your-satellite-address"
API_KEY="your-api-key"
PASSPHRASE="your-passphrase"
```

## Scripts Overview

- **`setup.sh`**: Main setup script that pulls the repository, sets up the crontab, and ensures all scripts are deployed correctly.
- **`Q_backup.sh`**: Backup script to upload files to StorJ. It sources sensitive data from `.storj_env`.
- **`change_hostname.sh`**: Changes the hostname of the server.
- **`setup_custom_nodes.sh`**: Script for setting up custom nodes (specific details depend on your node setup).
- **`stop_node_script.py`**: Python script for stopping a node.
- **`set_cpu_performance.sh`**: Script to configure the server's CPU for performance mode (run at startup and periodically).

## How to Customize Crontab

The crontab entries are stored in `crontab.txt`. Any changes to this file will be applied when you run `setup.sh`. Modify this file directly in the repository to update the cron jobs across all servers.

---

## Troubleshooting

- Ensure `git` is installed on the server. The `setup.sh` script will attempt to install it if it's missing.
- Always manually edit `.storj_env` on each server to keep sensitive data safe.
```

---

### **Understanding `.gitignore`**

A `.gitignore` file is used to tell Git which files or directories should **not** be tracked or committed to the GitHub repository. This is useful for keeping sensitive or system-specific files out of the repository, like environment files or local logs.

In your case, you want to ensure that `.storj_env` is never committed to GitHub because it contains sensitive information (such as API keys and passwords). We’ll add this to the `.gitignore` file.

Here’s how your `.gitignore` file will look:

```bash
# Ignore the environment file containing sensitive data
.storj_env

# Optionally, you can ignore log directories or other system-specific files
log/
logs/
*.log
```

### What This Does:

- **`.storj_env`**: Ensures that your sensitive `.storj_env` file is ignored by Git and never pushed to the repository.
- **`log/`, `logs/`**: If you have any log directories in your project, this will prevent logs from being tracked by Git.
- **`*.log`**: This tells Git to ignore any files with the `.log` extension (e.g., logs generated by your scripts).

### Why This is Important:
- **Security**: By ignoring `.storj_env`, you prevent sensitive data like API keys from being exposed on GitHub.
- **Clean Commits**: Avoid cluttering your repository with logs or system-specific files that don’t need to be shared across servers.
