#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# -----------------------------
# Define Colors for Output
# -----------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RESET='\033[0m'

print_status() {
    echo -e "${BLUE}[*] $1${RESET}"
}

print_success() {
    echo -e "${GREEN}[+] $1${RESET}"
}

print_error() {
    echo -e "${RED}[-] $1${RESET}"
}

print_info() {
    echo -e "${YELLOW}[i] $1${RESET}"
}

# -----------------------------
# Verify Prerequisites
# -----------------------------
print_status "Verifying prerequisites..."

# Check if the script is run as root
if [[ "$EUID" -ne 0 ]]; then
    print_error "This script must be run as root. Use sudo."
    exit 1
fi

# Check if Zenity is installed
if ! command -v zenity &>/dev/null; then
    print_status "Zenity is not installed. Installing it now..."
    apt-get update && apt-get install -y zenity
else
    print_success "Zenity is already installed."
fi

# -----------------------------
# Install Helpx Globally
# -----------------------------
print_status "Installing helpx globally..."

# Define paths
HELPTX_SCRIPT_PATH="$(pwd)/helpx.sh"
INSTALL_PATH="/usr/local/bin/helpx"

# Ensure helpx.sh exists in the current directory
if [[ ! -f "$HELPTX_SCRIPT_PATH" ]]; then
    print_error "helpx.sh not found in the current directory. Please ensure it's in $(pwd)."
    exit 1
fi

# Copy helpx.sh to /usr/local/bin
cp "$HELPTX_SCRIPT_PATH" "$INSTALL_PATH"
chmod +x "$INSTALL_PATH"

# Verify installation
if command -v helpx &>/dev/null; then
    print_success "helpx installed successfully at $INSTALL_PATH."
else
    print_error "Failed to install helpx. Please check permissions or paths."
    exit 1
fi

# -----------------------------
# Setup User's PATH
# -----------------------------
print_status "Ensuring /usr/local/bin is in PATH..."

# Check if /usr/local/bin is in PATH
if ! echo "$PATH" | grep -q "/usr/local/bin"; then
    print_status "/usr/local/bin is not in PATH. Adding it now..."
    
    # Add to bashrc and zshrc
    echo 'export PATH=$PATH:/usr/local/bin' >> ~/.bashrc
    echo 'export PATH=$PATH:/usr/local/bin' >> ~/.zshrc
    
    print_success "/usr/local/bin added to PATH. Please reload your shell."
else
    print_success "/usr/local/bin is already in PATH."
fi

# -----------------------------
# Create Helptopics Directory
# -----------------------------
print_status "Creating helptopics directory..."

USER_HOME=$(eval echo "~$SUDO_USER")
HELPTOPICS_DIR="$USER_HOME/.helptopics"

mkdir -p "$HELPTOPICS_DIR"
chown "$SUDO_USER":"$SUDO_USER" "$HELPTOPICS_DIR"
chmod 755 "$HELPTOPICS_DIR"

print_success "Helptopics directory created at $HELPTOPICS_DIR."

# -----------------------------
# Log File Setup
# -----------------------------
print_status "Creating helpx log file..."

LOG_FILE="$HELPTOPICS_DIR/.helpx.log"

if [[ ! -f "$LOG_FILE" ]]; then
    touch "$LOG_FILE"
    chown "$SUDO_USER":"$SUDO_USER" "$LOG_FILE"
    chmod 664 "$LOG_FILE"
    print_success "Log file created at $LOG_FILE."
else
    print_success "Log file already exists at $LOG_FILE."
fi

# -----------------------------
# Final Output
# -----------------------------
print_success "Helpx installation and setup completed successfully!"
print_info "To use helpx, run: helpx"
print_info "To reload your shell, run: source ~/.bashrc or source ~/.zshrc"

exit 0
