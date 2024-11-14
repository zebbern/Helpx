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
source "$(dirname "$0")/utils/logging.sh"

# Load configuration
source "$(dirname "$0")/config/settings.conf"

# Trap errors
trap 'print_error "An unexpected error occurred. Exiting..."; exit 1;' ERR

# Validate dependencies
source "$(dirname "$0")/modules/dependencies.sh"

# Install dependencies
source "$(dirname "$0")/modules/dependencies.sh"

# Install Python libraries
source "$(dirname "$0")/modules/python.sh"

# Install Go and Go-based tools
source "$(dirname "$0")/modules/go.sh"

# Install recon and bug bounty tools
source "$(dirname "$0")/modules/tools.sh"

# Configure system settings
source "$(dirname "$0")/modules/config.sh"

# Setup cron jobs
source "$(dirname "$0")/modules/cron.sh"

# Setup helptx
source "$(dirname "$0")/modules/helpx.sh"

# Cleanup
source "$(dirname "$0")/modules/cleanup.sh"

# Report Summary
source "$(dirname "$0")/modules/report.sh"

# Prompt for Restart
source "$(dirname "$0")/modules/restart_prompt.sh"
