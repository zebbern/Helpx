#!/bin/bash

# Colors for Output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly RESET='\033[0m'

# Logging functions
print_status() {
    echo -e "${BLUE}[*] $1${RESET}"
}

print_success() {
    echo -e "${GREEN}[+] $1${RESET}"
}

print_error() {
    echo -e "${RED}[-] $1${RESET}" >&2
}
