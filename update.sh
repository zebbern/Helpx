#!/bin/bash

# Ensure execution without requiring chmod +x
# Place this file in a directory in your PATH (like /usr/local/bin) or run via bash tool.sh

# Detect user shell (zsh or bash)
USER_SHELL=$(basename "$SHELL")
echo "Detected shell: $USER_SHELL"

# Set appropriate rc file based on detected shell
if [ "$USER_SHELL" == "zsh" ]; then
    RC_FILE="$HOME/.zshrc"
elif [ "$USER_SHELL" == "bash" ]; then
    RC_FILE="$HOME/.bashrc"
else
    echo "Unsupported shell. Please use bash or zsh."
    exit 1
fi

# Set PATH and update shell environment
update_shell_path() {
    echo 'export PATH=$PATH:~/go/bin' >> "$RC_FILE"
    source "$RC_FILE" || . "$RC_FILE"
}

# Function to install a package if not already installed
install_package() {
    PACKAGE_NAME="$1"
    if ! dpkg -s "$PACKAGE_NAME" &>/dev/null; then
        sudo apt install -y "$PACKAGE_NAME"
    else
        echo "$PACKAGE_NAME is already installed."
    fi
}

# Update repositories and upgrade system
echo "Updating system..."
sudo apt update -y && sudo apt upgrade -y

# Install Python 3.11 if it improves compatibility
echo "Installing Python 3.11 and dependencies..."
if ! python3 --version | grep -q "3.11"; then
    sudo apt install -y software-properties-common
    sudo add-apt-repository -y ppa:deadsnakes/ppa
    sudo apt update -y
    install_package python3.11
    install_package python3.11-venv
    install_package python3.11-dev
else
    echo "Python 3.11 is already installed."
fi

# Check for Go language installation for Go-based tools
if ! command -v go &>/dev/null; then
    echo "Installing Go language..."
    sudo apt install -y golang
    update_shell_path
fi

# Install fzf if it has no downsides
if ! command -v fzf &>/dev/null; then
    echo "Installing fzf..."
    install_package fzf
    echo "fzf installed to enhance terminal search functionality."
fi

# Install GitHub CLI for GitHub Recon
echo "Installing GitHub CLI..."
install_package gh

# Install Recon and Bug Bounty Tools
echo "Installing Recon and Bug Bounty tools..."
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install -v github.com/OWASP/Amass/v3/...@latest
go install -v github.com/tomnomnom/gf@latest
go install -v github.com/tomnomnom/httprobe@latest
go install -v github.com/tomnomnom/meg@latest
go install -v github.com/hakluke/hackerone-recon@latest

# Install HTTP/Web Exploitation Tools
echo "Installing HTTP and Web Exploitation tools..."
install_package gobuster
install_package ffuf
install_package nmap
install_package wfuzz
install_package dirsearch

# Install Nuclei Templates Auto-Updater (cron job)
echo "Configuring Nuclei Templates Auto-Updater..."
install_package nuclei
(crontab -l ; echo "0 2 * * * nuclei -update-templates") | crontab -

# Preload installation if beneficial (conditional)
if ! command -v preload &>/dev/null; then
    echo "Installing preload for optimized system performance..."
    install_package preload
fi

# Install critical libraries
echo "Installing critical Python libraries..."
PYTHON_LIBS=(
    aiosmb aiowinreg asn1crypto bcrypt beautifulsoup4 bloodhound chardet colorama csvkit
    dissect dnspython eml_parser filemagic Flask future futures impacket ipaddress IPy
    itsdangerous Jinja2 ldap3 ldapdomaindump lxml markdownify minidump minikerberos msldap
    networkx nmaptocsv webscreenshot packaging pandas paramiko passlib pbkdf2 px-proxy
    pyasn1 pycryptodome PyPDF2 pyinstaller pywerview requests scrypt termcolor urllib3
    validators vulners waybackpy winacl w3lib XlsxWriter
)
for LIB in "${PYTHON_LIBS[@]}"; do
    pip install "$LIB"
done

# Create helpx function with external help files
HELPTOPIC_DIR="$HOME/.helptopics"
mkdir -p "$HELPTOPIC_DIR"

helpx() {
    echo "Available Help Topics:"
    for file in "$HELPTOPIC_DIR"/*; do
        topic=$(basename "$file")
        echo "- $topic"
    done
    read -p "Enter topic name to view details (or type 'exit' to quit): " topic_choice
    if [[ "$topic_choice" == "exit" ]]; then
        return
    elif [[ -f "$HELPTOPIC_DIR/$topic_choice" ]]; then
        cat "$HELPTOPIC_DIR/$topic_choice"
    else
        echo "Help topic not found."
    fi
}

# Cron Job Management Functions
manage_crontab() {
    echo "Available cron jobs:"
    crontab -l
    echo "Would you like to (a)dd, (r)emove, or (v)iew a cron job?"
    read -p "Enter your choice (a/r/v): " cron_action
    case $cron_action in
        a)
            read -p "Enter the cron job to add (e.g., '0 2 * * * nuclei -update-templates'): " new_cron
            (crontab -l; echo "$new_cron") | crontab -
            echo "Cron job added."
            ;;
        r)
            read -p "Enter the cron job number to remove: " job_number
            crontab -l | nl
            sed -i "${job_number}d" <(crontab -l) 
            echo "Cron job removed."
            ;;
        v)
            echo "Viewing current cron jobs:"
            crontab -l
            ;;
        *)
            echo "Invalid option."
            ;;
    esac
}

# Make helpx accessible in all sessions
echo "Adding helpx function to $RC_FILE..."
echo "helpx() {" >> "$RC_FILE"
echo "    $(declare -f helpx | tail -n +2)" >> "$RC_FILE"
echo "}" >> "$RC_FILE"
echo "alias helpx='helpx'" >> "$RC_FILE"
echo "alias managecron='manage_crontab'" >> "$RC_FILE"
source "$RC_FILE"

# GitHub setup for easy cloning
echo "To install this setup from GitHub, use the following commands:"
echo "1. git clone https://github.com/zebbern/AutoKali.git"
echo "2. cd AutoKali"
echo "3. bash setup.sh"

# Confirm installation completion
echo "Setup complete! You can now use 'helpx' to access custom help topics and 'managecron' to manage cron jobs."
