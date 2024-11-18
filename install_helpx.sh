#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# -----------------------------
# Define Colors for Output
# -----------------------------
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

print_success() {
    echo -e "${GREEN}[+] $1${RESET}"
}

print_error() {
    echo -e "${RED}[-] $1${RESET}"
}

# -----------------------------
# Copy and Set Up Helpx Script
# -----------------------------

# Ensure helpx.sh exists in the current directory
if [[ ! -f "./helpx.sh" ]]; then
    print_error "helpx.sh not found in the current directory. Ensure it exists before running this script."
    exit 1
fi

# Copy helpx.sh to /usr/local/bin
sudo cp ./helpx.sh /usr/local/bin/helpx
sudo chmod +x /usr/local/bin/helpx

# Verify installation
if command -v helpx &>/dev/null; then
    print_success "Helpx installed successfully at /usr/local/bin/helpx."
else
    print_error "Failed to install helpx. Please check permissions or paths."
    exit 1
fi

exit 0
