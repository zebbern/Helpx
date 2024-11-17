#!/bin/bash

# -----------------------------
# Module: config.sh
# Description: Configures environment settings
# -----------------------------

configure_environment() {
    print_status "Configuring environment settings..."

    # Ensure the shell RC file exists
    if [ ! -f "$RC_FILE" ]; then
        touch "$RC_FILE"
        print_status "Created shell configuration file: $RC_FILE"
    fi

    # Add environment variables if not present
    if ! grep -q "# Go environment variables" "$RC_FILE"; then
        {
            echo ""
            echo "# Go environment variables"
            echo 'export GOPATH=$HOME/go'
            echo 'export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin'
        } >> "$RC_FILE"
        print_success "Go environment variables added to $RC_FILE."
    else
        print_success "Go environment variables already exist in $RC_FILE."
    fi

    # Inform the user to reload the shell
    print_status "Please reload your shell or run 'source $RC_FILE' to apply the changes."
}

configure_environment
