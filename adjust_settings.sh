#!/bin/bash

# -----------------------------
# Script: adjust_settings.sh
# Description: Makes everything bigger for better visibility on Kali Linux (Xfce).
# -----------------------------

set -e

# -----------------------------
# Color Codes for Output
# -----------------------------
COLOR_RESET="\e[0m"
COLOR_BLUE="\e[34m"
COLOR_GREEN="\e[32m"
COLOR_RED="\e[31m"
COLOR_YELLOW="\e[33m"

# -----------------------------
# Functions for Output Messages
# -----------------------------
print_status() {
    echo -e "${COLOR_BLUE}[*] $1${COLOR_RESET}"
}

print_success() {
    echo -e "${COLOR_GREEN}[+] $1${COLOR_RESET}"
}

print_error() {
    echo -e "${COLOR_RED}[-] $1${COLOR_RESET}"
}

print_warning() {
    echo -e "${COLOR_YELLOW}[!] $1${COLOR_RESET}"
}

# -----------------------------
# Function to Install Missing Commands
# -----------------------------
install_command() {
    local cmd="$1"
    local pkg="$2"

    if ! command -v "$cmd" >/dev/null 2>&1; then
        print_warning "Command '$cmd' not found. Attempting to install package '$pkg'..."
        sudo apt-get update
        sudo apt-get install -y "$pkg"
        if command -v "$cmd" >/dev/null 2>&1; then
            print_success "Successfully installed '$cmd'."
        else
            print_error "Failed to install '$cmd'. Please install it manually and rerun the script."
            exit 1
        fi
    else
        print_success "Command '$cmd' is already installed."
    fi
}

# -----------------------------
# Determine the Active User
# -----------------------------
if [ "$SUDO_USER" ]; then
    ACTIVE_USER="$SUDO_USER"
else
    ACTIVE_USER="$(whoami)"
fi

# -----------------------------
# Check and Install Required Commands
# -----------------------------
REQUIRED_COMMANDS=("xfconf-query" "xfce4-power-manager" "gsettings" "dconf" "xrdb" "apt-get")
declare -A COMMAND_PACKAGE_MAP
COMMAND_PACKAGE_MAP=(
    ["xfconf-query"]="xfconf"
    ["xfce4-power-manager"]="xfce4-power-manager"
    ["gsettings"]="dconf-cli"
    ["dconf"]="dconf-cli"
    ["xrdb"]="x11-xserver-utils"
    ["apt-get"]="apt"
)

for cmd in "${REQUIRED_COMMANDS[@]}"; do
    pkg="${COMMAND_PACKAGE_MAP[$cmd]}"
    install_command "$cmd" "$pkg"
done

# -----------------------------
# OS and Desktop Environment Check
# -----------------------------
if ! grep -q "Kali" /etc/os-release; then
    print_warning "This script is designed for Kali Linux. Proceeding with caution."
fi

if ! ps -e | grep -q "xfce4-session"; then
    print_error "This script is designed for the Xfce desktop environment. Exiting."
    exit 1
fi

# -----------------------------
# Adjust Terminal Font Size
# -----------------------------
adjust_terminal_font() {
    print_status "Adjusting terminal font size..."
    FONT_SIZE=18
    xfconf-query -c xfce4-terminal -p /xfce4-terminal/font -s "Monospace ${FONT_SIZE}" 2>/dev/null || {
        print_error "Failed to adjust terminal font size. Please check your xfce4-terminal configuration."
        return 1
    }
    print_success "Terminal font size set to ${FONT_SIZE}."
}

# -----------------------------
# Adjust Desktop Background Scaling
# -----------------------------
adjust_background_scaling() {
    print_status "Adjusting desktop background scaling..."
    xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-style -s 5
    IMAGE_PATH=$(xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-path | tr -d '"')
    if [ -n "$IMAGE_PATH" ]; then
        xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image --create -t string -s "$IMAGE_PATH"
    fi
    print_success "Desktop background scaling set to Zoom."
}

# -----------------------------
# Adjust Window Scaling (DPI and Scale Factor)
# -----------------------------
adjust_window_scaling() {
    print_status "Adjusting window scaling..."
    DPI=144
    xrdb -merge <<< "Xft.dpi: $DPI"
    gsettings set org.gnome.desktop.interface scaling-factor 2 || true
    xfconf-query -c xsettings -p /Xft/DPI -s $((DPI * 1024))
    print_success "Window scaling adjusted to DPI=$DPI."
}

# -----------------------------
# Adjust Power Settings
# -----------------------------
adjust_power_settings() {
    print_status "Adjusting power settings..."
    xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/display-sleep-on-ac -s 10
    xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/sleep-on-ac -s 30
    print_success "Power settings adjusted."
}

# -----------------------------
# Adjust Panel and Icon Sizes
# -----------------------------
adjust_panel_and_icons() {
    print_status "Adjusting panel and icon sizes..."
    PANEL_HEIGHT=40
    xfconf-query -c xfce4-panel -p /panels/panel-1/size -s "$PANEL_HEIGHT" 2>/dev/null || {
        print_error "Failed to set panel height. Check your xfce4-panel configuration."
        return 1
    }
    print_success "Panel height set to ${PANEL_HEIGHT}px."

    ICON_SIZE=64
    if xfconf-query -c xfce4-panel -p /plugins/plugin-ids >/dev/null 2>&1; then
        xfconf-query -c xfce4-panel -p /plugins/plugin-ids | tr -d '"' | while read -r plugin_id; do
            if [[ "$plugin_id" == "launcher"* ]]; then
                xfconf-query -c xfce4-panel -p "/plugins/plugin-${plugin_id}/launcher/icon-size" -s "$ICON_SIZE"
            fi
        done
        print_success "Panel icon sizes set."
    else
        print_warning "No plugins found in xfce4-panel. Skipping icon size adjustment."
    fi
}

# -----------------------------
# Enable Dark Mode
# -----------------------------
enable_dark_mode() {
    print_status "Enabling dark mode..."
    gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark" || true
    gsettings set org.gnome.desktop.interface icon-theme "Adwaita" || true
    print_success "Dark mode enabled."
}

# -----------------------------
# Adjust Mouse Settings
# -----------------------------
adjust_mouse_settings() {
    print_status "Adjusting mouse settings..."
    gsettings set org.gnome.desktop.interface cursor-size 32 || true
    gsettings set org.gnome.desktop.peripherals.mouse natural-scroll true || true
    print_success "Mouse settings adjusted."
}

# -----------------------------
# Main Execution
# -----------------------------
main() {
    print_status "Starting system settings adjustment..."
    adjust_terminal_font
    adjust_background_scaling
    adjust_window_scaling
    adjust_power_settings
    adjust_panel_and_icons
    enable_dark_mode
    adjust_mouse_settings
    print_success "All settings adjusted successfully."
    read -rp "Restart now? [Y/n]: " yn
    if [[ "$yn" =~ ^[Yy]$ ]] || [[ -z "$yn" ]]; then
        sudo reboot
    else
        print_status "Restart later for changes to take effect."
    fi
}

main
