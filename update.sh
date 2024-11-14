#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# -----------------------------
# Colors for Output
# -----------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RESET='\033[0m'

# -----------------------------
# Helper Functions
# -----------------------------
print_status() {
  echo -e "${BLUE}[*] $1${RESET}"
}

print_success() {
  echo -e "${GREEN}[+] $1${RESET}"
}

print_error() {
  echo -e "${RED}[-] $1${RESET}"
}

# -----------------------------
# Ensure Script is Run as Root
# -----------------------------
if [[ "$EUID" -ne 0 ]]; then
  print_error "This script must be run as root. Use sudo."
  exit 1
fi

print_status "Starting Bug Bounty and Pentesting setup..."

# -----------------------------
# Detect Active User and Shell
# -----------------------------
print_status "Detecting active user and shell..."

# Determine the non-root user invoking sudo
if [ "$SUDO_USER" ]; then
    ACTIVE_USER="$SUDO_USER"
else
    ACTIVE_USER=$(whoami)
fi

# Verify that ACTIVE_USER exists in the passwd database
if ! getent passwd "$ACTIVE_USER" > /dev/null; then
    print_error "User '$ACTIVE_USER' does not exist."
    exit 1
fi

# Get the shell of the active user
SHELL_PATH=$(getent passwd "$ACTIVE_USER" | cut -d: -f7)

if [ -z "$SHELL_PATH" ]; then
    print_error "Could not determine the shell for user '$ACTIVE_USER'."
    exit 1
fi

USER_SHELL=$(basename "$SHELL_PATH")

if [ "$USER_SHELL" == "zsh" ]; then
    RC_FILE="/home/$ACTIVE_USER/.zshrc"
    print_success "Detected shell: zsh. Using RC file: $RC_FILE"
elif [ "$USER_SHELL" == "bash" ]; then
    RC_FILE="/home/$ACTIVE_USER/.bashrc"
    print_success "Detected shell: bash. Using RC file: $RC_FILE"
else
    print_error "Unsupported shell detected: $USER_SHELL. This script supports only bash and zsh."
    exit 1
fi

# -----------------------------
# Update and Upgrade System
# -----------------------------
print_status "Updating and upgrading system..."
apt update -y && apt upgrade -y

# -----------------------------
# Function to Install a Package if Not Installed
# -----------------------------
install_package() {
    PACKAGE_NAME="$1"
    if ! dpkg -s "$PACKAGE_NAME" &>/dev/null; then
        print_status "Installing $PACKAGE_NAME..."
        apt install -y "$PACKAGE_NAME"
    else
        echo "$PACKAGE_NAME is already installed."
    fi
}

# -----------------------------
# Install Dependencies (Excluding Python)
# -----------------------------
print_status "Installing essential dependencies..."
ESSENTIALS=(
    build-essential
    libssl-dev
    zlib1g-dev
    libbz2-dev
    libreadline-dev
    libsqlite3-dev
    wget
    curl
    llvm
    libncurses5-dev
    libncursesw5-dev
    xz-utils
    tk-dev
    libffi-dev
    liblzma-dev
    git
    libgdbm-dev
    libnss3-dev
    libgdbm-compat-dev
    software-properties-common
    python3-pip
    python3-venv
)
for pkg in "${ESSENTIALS[@]}"; do
    install_package "$pkg"
done

# -----------------------------
# Function to Install Global Python Libraries
# -----------------------------
install_python_libraries() {
    print_status "Installing Python libraries globally..."
    PYTHON_LIBS=(
        requests
        beautifulsoup4
        flask
        colorama
        pandas
        scapy
        paramiko
        pyyaml
        cryptography
        sqlalchemy
    )

    for LIB in "${PYTHON_LIBS[@]}"; do
        echo "Installing $LIB..."
        pip3 install "$LIB" || echo "Failed to install $LIB"
    done
    print_success "Python libraries installation complete."
}

install_python_libraries

# -----------------------------
# Function to Install Go and Go-Based Tools
# -----------------------------
install_go_and_tools() {
    if ! command -v go &>/dev/null; then
        print_status "Installing Go..."
        wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz -O /tmp/go.tar.gz
        tar -C /usr/local -xzf /tmp/go.tar.gz
        rm /tmp/go.tar.gz
        # Ensure /usr/local/go/bin and ~/go/bin are in PATH
        echo 'export PATH=$PATH:/usr/local/go/bin:~/go/bin' >> "$RC_FILE"
        # Ensure the active user has access to Go path
        su - "$ACTIVE_USER" -c "echo 'export PATH=\$PATH:/usr/local/go/bin:~/go/bin' >> $RC_FILE"
        # Reload shell configuration for active user
        su - "$ACTIVE_USER" -c "source $RC_FILE"
        print_success "Go installed successfully."
    else
        echo "Go is already installed."
    fi

    print_status "Installing Go-based tools..."
    GO_TOOLS=(
        github.com/tomnomnom/waybackurls
        github.com/projectdiscovery/nuclei/v2/cmd/nuclei
        github.com/projectdiscovery/httpx/cmd/httpx
        github.com/tomnomnom/assetfinder
        github.com/lc/gau
        github.com/tomnomnom/httprobe
        github.com/hakluke/hackerone-recon
    )

    for tool in "${GO_TOOLS[@]}"; do
        TOOL_NAME=$(basename "$tool")
        if ! command -v "$TOOL_NAME" &>/dev/null; then
            print_status "Installing $TOOL_NAME..."
            su - "$ACTIVE_USER" -c "go install ${tool}@latest" || echo "Failed to install $TOOL_NAME"
        else
            echo "$TOOL_NAME is already installed."
        fi
    done

    # Ensure Go binaries are in PATH for active user
    echo 'export PATH=$PATH:~/go/bin' >> "$RC_FILE"
    su - "$ACTIVE_USER" -c "source $RC_FILE"

    print_success "Go-based tools installation complete."
}

install_go_and_tools

# -----------------------------
# Function to Install Recon and Bug Bounty Tools via apt
# -----------------------------
install_recon_bugbounty_tools() {
    print_status "Installing Recon and Bug Bounty tools via apt..."
    APT_RECON_TOOLS=(
        nmap
        masscan
        gobuster
        ffuf
        wfuzz
        dirsearch
        nuclei
        gh  # GitHub CLI
    )

    for tool in "${APT_RECON_TOOLS[@]}"; do
        install_package "$tool"
    done
    print_success "Recon and Bug Bounty tools installation via apt complete."
}

install_recon_bugbounty_tools

# -----------------------------
# Function to Install Browser Automation Tools via npm
# -----------------------------
install_browser_automation_tools() {
    print_status "Installing Browser Automation Tools (Puppeteer, Playwright)..."
    install_package npm
    # Install as the active user
    su - "$ACTIVE_USER" -c "npm install -g puppeteer playwright" || { print_error "Failed to install Puppeteer or Playwright"; }
    print_success "Browser Automation Tools installed."
}

install_browser_automation_tools

# -----------------------------
# Function to Install GitHub Recon Tools
# -----------------------------
install_github_recon_tools() {
    print_status "Installing GitHub Recon Tools..."
    if ! command -v hackerone-recon &>/dev/null; then
        su - "$ACTIVE_USER" -c "go install github.com/hakluke/hackerone-recon@latest" || echo "Failed to install hackerone-recon"
    else
        echo "hackerone-recon is already installed."
    fi
    print_success "GitHub Recon Tools installation complete."
}

install_github_recon_tools

# -----------------------------
# Function to Setup Nuclei Templates Auto-Updater
# -----------------------------
setup_nuclei_auto_update() {
    print_status "Setting up Nuclei templates auto-updater (cron job)..."
    if command -v nuclei &>/dev/null; then
        # Check if cron job already exists
        crontab -l 2>/dev/null | grep -q "nuclei -update-templates" && echo "Cron job already exists." || (crontab -l 2>/dev/null; echo "0 2 * * * nuclei -update-templates") | crontab -
        print_success "Nuclei templates auto-updater scheduled."
    else
        print_error "Nuclei is not installed. Cannot set up auto-updater."
    fi
}

setup_nuclei_auto_update

# -----------------------------
# Function to Setup Helpx Command as Standalone Script
# -----------------------------
setup_helpx() {
    print_status "Setting up 'helpx' command..."

    # Create helptopics directory
    HELPTOPIC_DIR="/home/$ACTIVE_USER/.helptopics"
    sudo -u "$ACTIVE_USER" mkdir -p "$HELPTOPIC_DIR"

    # Create an example help topic
    sudo -u "$ACTIVE_USER" tee "$HELPTOPIC_DIR/waybackurls_grep.txt" > /dev/null <<'EOF'
# Waybackurls Grep Help
# ---------------------
# Edit hackerone.com to your URL
# Usage:
# waybackurls hackerone.com | grep -E --color '(\.xls|\.tar\.gz|\.bak|\.xml|\.xlsx|\.json|\.rar|\.pdf|\.sql|\.docx?|\.pptx|\.txt|\.zip|\.tgz|\.7z)$'

waybackurls hackerone.com | grep -E --color '(\.xls|\.tar\.gz|\.bak|\.xml|\.xlsx|\.json|\.rar|\.pdf|\.sql|\.docx?|\.pptx|\.txt|\.zip|\.tgz|\.7z)$'

# Example for OAuth2 Config Search
curl [yourdomain.com]/login?next=/ | grep -o '"oauth2Config": \[.*\]' | sed 's/"oauth2Config": //'
EOF

    # Create the helpx script in /usr/local/bin
    HELPX_SCRIPT="/usr/local/bin/helpx"

    sudo tee "$HELPX_SCRIPT" > /dev/null <<'EOL'
#!/bin/bash

HELP_DIR="$HOME/.helptopics"

manage_cron_jobs() {
    echo "Cron Job Management"
    echo "-------------------"
    echo "1. View current cron jobs"
    echo "2. Add a new cron job"
    echo "3. Remove a cron job"
    echo "4. Exit"
    echo
    read -p "Enter your choice (1-4): " cron_choice

    case $cron_choice in
        1)
            echo "Current cron jobs:"
            crontab -l || echo "No cron jobs set."
            ;;
        2)
            read -p "Enter cron schedule (e.g., '0 2 * * *'): " cron_schedule
            read -p "Enter the command to run: " cron_command
            (crontab -l 2>/dev/null; echo "$cron_schedule $cron_command") | crontab -
            echo "Cron job added."
            ;;
        3)
            echo "Existing cron jobs:"
            crontab -l | nl
            read -p "Enter the cron job number to remove: " cron_num
            crontab -l | sed "${cron_num}d" | crontab -
            echo "Cron job #$cron_num removed."
            ;;
        4)
            echo "Exiting cron job management."
            ;;
        *)
            echo "Invalid choice. Please select between 1-4."
            ;;
    esac
}

if [[ "$1" == "-cron" ]]; then
    manage_cron_jobs
elif [[ "$1" == "create" ]]; then
    read -p "Enter topic name for help page (no spaces): " topic_name
    if [[ -z "$topic_name" ]]; then
        echo "Topic name cannot be empty."
        exit 1
    fi
    touch "$HELP_DIR/$topic_name.txt"
    echo "Help page '$topic_name' created. Please edit it with your content." > "$HELP_DIR/$topic_name.txt"
    echo "You can edit it using: nano $HELP_DIR/$topic_name.txt"
elif [[ -f "$HELP_DIR/$1.txt" ]]; then
    cat "$HELP_DIR/$1.txt"
elif [[ -z "$1" ]]; then
    echo "Helpx: Create, view, and manage help pages and cron jobs"
    echo "Usage:"
    echo "  helpx <topic>       - View a specific help topic"
    echo "  helpx create        - Create a new help topic"
    echo "  helpx -cron         - Manage cron jobs"
    echo
    echo "Available Help Topics:"
    for file in "$HELP_DIR"/*.txt; do
        [ -e "$file" ] || continue
        topic=$(basename "$file" .txt)
        echo "  - $topic"
    done
else
    echo "Help topic '$1' not found."
fi
EOL

    # Make helpx executable
    chmod +x "$HELPX_SCRIPT"

    # Ensure /usr/local/bin is in PATH for active user
    if ! su - "$ACTIVE_USER" -c "echo \$PATH" | grep -q "/usr/local/bin"; then
        echo 'export PATH=$PATH:/usr/local/bin' >> "$RC_FILE"
    fi

    # Reload shell configuration for active user
    su - "$ACTIVE_USER" -c "source $RC_FILE"

    print_success "'helpx' command setup complete. You can now use 'helpx' as a command."
}

setup_helpx

# -----------------------------
# Handle Broken Packages
# -----------------------------
fix_broken_packages() {
    print_status "Checking for broken packages..."
    apt --fix-broken install -y || echo "No broken packages found or unable to fix."
}

fix_broken_packages

# -----------------------------
# Cleanup Function
# -----------------------------
cleanup() {
    print_status "Cleaning up unnecessary packages..."
    apt autoremove -y
    apt clean
}

cleanup

# -----------------------------
# Function to Report Summary
# -----------------------------
report_summary() {
    echo "----------------------------------------"
    echo "Installation Summary:"
    echo "----------------------------------------"
    echo "1. Essential dependencies installed."
    echo "2. Python libraries installed globally."
    echo "3. Go language installed."
    echo "4. Go-based tools installed."
    echo "5. Recon and Bug Bounty tools installed via apt."
    echo "6. Browser Automation Tools installed."
    echo "7. GitHub Recon Tools installed."
    echo "8. Nuclei Templates Auto-Updater scheduled."
    echo "9. 'helpx' command installed."
    echo "----------------------------------------"
    echo "Please check above for any 'Failed to install' messages."
    echo "----------------------------------------"
}

report_summary

# -----------------------------
# Prompt for Restart
# -----------------------------
prompt_restart() {
    echo
    echo "Would you like to restart now or later?"
    select RESTART in "Now" "Later"; do
        case $RESTART in
            "Now")
                print_status "System will restart now."
                reboot
                break
                ;;
            "Later")
                print_status "You can restart later. Setup is complete."
                break
                ;;
            *)
                echo "Invalid option. Please choose 1 or 2."
                ;;
        esac
    done
}

prompt_restart
