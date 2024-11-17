#!/bin/bash

# -----------------------------
# Module: go.sh
# Description: Installs Go and Go-based tools
# -----------------------------

install_go() {
    # Check if Go is already installed
    if ! /usr/local/go/bin/go version &>/dev/null; then
        print_status "Installing Go..."
        GO_VERSION="1.21.0"
        wget "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" -O /tmp/go.tar.gz || { print_error "Failed to download Go tarball."; exit 1; }
        sudo tar -C /usr/local -xzf /tmp/go.tar.gz || { print_error "Failed to extract Go tarball."; exit 1; }
        rm /tmp/go.tar.gz

        # Ensure 'go' binary is executable
        sudo chmod +x /usr/local/go/bin/go

        # Update PATH for the script's execution context
        export PATH=$PATH:/usr/local/go/bin:/home/$ACTIVE_USER/go/bin

        # Verify installation
        if /usr/local/go/bin/go version &>/dev/null; then
            print_success "Go ${GO_VERSION} installed successfully."
        else
            print_error "Go installation failed."
            exit 1
        fi

        # Ensure the shell RC file exists
        if [ ! -f "$RC_FILE" ]; then
            touch "$RC_FILE"
            print_status "Created shell configuration file: $RC_FILE"
        fi

        # Add Go environment variables if not present
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
    else
        print_success "Go is already installed."
    fi
}

install_go

install_go_tools() {
    print_status "Installing Go-based tools..."
    GO_TOOLS=(
        github.com/tomnomnom/waybackurls
        github.com/projectdiscovery/nuclei/v2/cmd/nuclei
        github.com/projectdiscovery/httpx/cmd/httpx
        github.com/tomnomnom/assetfinder
        github.com/lc/gau
        github.com/tomnomnom/httprobe
    )

    for tool in "${GO_TOOLS[@]}"; do
        TOOL_NAME=$(basename "$tool")
        if ! command -v "$TOOL_NAME" &>/dev/null; then
            print_status "Installing $TOOL_NAME..."
            sudo -u "$ACTIVE_USER" /usr/local/go/bin/go install "${tool}@latest" || { 
                print_error "Failed to install $TOOL_NAME. Skipping..."
                continue
            }
            print_success "$TOOL_NAME installed successfully."
        else
            print_success "$TOOL_NAME is already installed."
        fi
    done

    # Ensure Go binaries are in PATH for the script's execution context
    export PATH=$PATH:/home/$ACTIVE_USER/go/bin

    print_success "Go-based tools installation complete."
}

install_go_tools
