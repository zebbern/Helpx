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

# Validate dependencies
source "$(dirname "$0")/dependencies.sh"

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

# Setup Helpx
source "$(dirname "$0")/helpx.sh"
# Requirements for Helpx
source "$(dirname "$0")/install_helpx.sh"
# Cleanup
# (Assuming there's cleanup logic here)
