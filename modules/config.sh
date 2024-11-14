#!/bin/bash

configure_environment() {
    print_status "Configuring environment settings..."

    # Example: Adding Go PATH is handled in go.sh

    # Additional configurations can be added here
    # Ensure no duplicate entries by checking markers
    if ! grep -q "# Added by Kali setup script" "$RC_FILE"; then
        echo "# Added by Kali setup script" >> "$RC_FILE"
        # Add other environment configurations here
    fi

    source "$RC_FILE"
    print_success "Environment configurations complete."
}

configure_environment
