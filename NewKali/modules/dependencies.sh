#!/bin/bash

print_status "Validating dependencies..."

validate_dependencies() {
    local dependencies=(wget curl git sudo)
    for cmd in "${dependencies[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            print_error "Required command '$cmd' is not installed. Please install it and rerun the script."
            exit 1
        fi
    done
}

validate_dependencies
print_success "All required dependencies are installed."
