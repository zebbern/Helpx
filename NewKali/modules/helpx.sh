#!/bin/bash

# -----------------------------
# Module: helptx.sh
# Description: Sets up the 'helpx' command
# -----------------------------

setup_helpx() {
    print_status "Setting up 'helpx' command..."

    # Define the helptx binary path
    HELPTX_BIN="/usr/local/bin/helpx"

    # Check if 'helpx' is already installed
    if [ -f "$HELPTX_BIN" ]; then
        print_success "'helpx' is already installed."
        return
    fi

    # Create the 'helpx' script
    cat << 'EOF' > "$HELPTX_BIN"
#!/bin/bash

# Simple helptx command for managing tools

show_help() {
    echo "helpx - Help command for managing tools"
    echo "Usage:"
    echo "  helptx list    - List all installed tools"
    echo "  helptx update  - Update all tools"
    echo "  helptx help    - Show this help message"
}

list_tools() {
    echo "Installed tools:"
    ls ~/go/bin
}

update_tools() {
    echo "Updating Go-based tools..."
    /usr/local/go/bin/go install -v all
    echo "Go-based tools updated."
}

# Parse command-line arguments
case "$1" in
    list)
        list_tools
        ;;
    update)
        update_tools
        ;;
    help|*)
        show_help
        ;;
esac
EOF

    # Make the 'helpx' script executable
    chmod +x "$HELPTX_BIN" || {
        print_error "Failed to make 'helpx' executable."
        return
    }

    print_success "'helpx' installed successfully at $HELPTX_BIN."
}

setup_helpx
