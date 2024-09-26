import subprocess
import time
import signal
import sys
from datetime import datetime

# Define the commands to be executed
commands = [
    "service ceremonyclient stop",
    "systemctl stop ceremonyclient.service",
    "pkill node",
    "pkill -f 'go run ./...'",
    "sudo service quil stop"
]

# Initialize variables
start_time = datetime.now()
command_count = 0
interval = 5  # seconds

# Function to execute each command and suppress any errors
def execute_command(cmd):
    try:
        subprocess.run(cmd, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except Exception as e:
        # Optional: log the error somewhere if you want to capture it
        pass

# Function to gracefully exit the script
def signal_handler(sig, frame):
    print("\nExiting script... Goodbye!")
    sys.exit(0)

# Register the signal handler for graceful exit using CTRL+C
signal.signal(signal.SIGINT, signal_handler)

# Main loop
print("Script started. Press Ctrl+C to stop.")
while True:
    # Execute all commands
    for cmd in commands:
        execute_command(cmd)

    # Increment the count of how many times the command has been run
    command_count += 1

    # Calculate how long the script has been running
    elapsed_time = datetime.now() - start_time

    # Display menu without printing multiple lines
    print(f"\rRunning for {elapsed_time} | Command sent {command_count} times", end="")

    # Wait for 5 seconds before the next iteration
    time.sleep(interval)
