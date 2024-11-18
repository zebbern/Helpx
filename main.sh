#!/bin/bash

# -----------------------------
# Kali Linux Initial Setup Script
# Version: 1.0.0
# Author: zebbern
# Description: Automates the installation of essential tools and configurations for bug bounty and penetration testing.
# -----------------------------

# Exit immediately if a command exits with a non-zero status
set -euo pipefail
IFS=$'\n\t'

# Load utility functions
source "$(dirname "$0")/logging.sh"

# Load configuration
source "$(dirname "$0")/settings.conf"

# Trap errors
trap 'print_error "An unexpected error occurred. Exiting..."; exit 1;' ERR

# Install dependencies
source "$(dirname "$0")/dependencies.sh"

# Install Python libraries
source "$(dirname "$0")/python.sh"

# Install Go and Go-based tools
source "$(dirname "$0")/go.sh"

# Install recon and bug bounty tools
source "$(dirname "$0")/tools.sh"

# Configure system settings
source "$(dirname "$0")/config.sh"

# Setup cron jobs
source "$(dirname "$0")/cron.sh"

# Install Helpx
echo "Setting up Helpx..."
bash "$(dirname "$0")/install_helpx.sh"
if [[ $? -eq 0 ]]; then
    echo "Helpx setup complete."
else
    echo "Helpx setup failed. Please check the output for errors."
    exit 1
fi

# Cleanup (if applicable)
# Add cleanup logic here if needed

# Final Message
echo "Setup completed successfully! You can now use the 'helpx' command globally."
