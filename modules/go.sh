#!/bin/bash

install_go() {
    if ! command -v go &>/dev/null; then
        print_status "Installing Go..."
        GO_VERSION="1.21.0"
        wget "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" -O /tmp/go.tar.gz
        tar -C /usr/local -xzf /tmp/go.tar.gz
        rm /tmp/go.tar.gz

        # Verify installation
        if command -v go &>/dev/null; then
            print_success "Go ${GO_VERSION} installed successfully."
        else
            print_error "Go installation failed."
            exit 1
        fi

        # Set environment variables if not already set
        if ! grep -q "# Go environment variables" "$RC_FILE"; then
            echo "# Go environment variables" >> "$RC_FILE"
            echo 'export GOPATH=$HOME/go' >> "$RC_FILE"
            echo 'export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin' >> "$RC_FILE"
        fi

        # Apply changes
        source "$RC_FILE"
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
        github.com/hakluke/hackerone-recon
    )

    for tool in "${GO_TOOLS[@]}"; do
        TOOL_NAME=$(basename "$tool")
        if ! command -v "$TOOL_NAME" &>/dev/null; then
            print_status "Installing $TOOL_NAME..."
            sudo -u "$ACTIVE_USER" go install "${tool}@latest" || { print_error "Failed to install $TOOL_NAME"; continue; }
            print_success "$TOOL_NAME installed successfully."
        else
            print_success "$TOOL_NAME is already installed."
        fi
    done

    # Ensure Go binaries are in PATH
    if ! grep -q "# Go binaries" "$RC_FILE"; then
        echo "# Go binaries" >> "$RC_FILE"
        echo 'export PATH=$PATH:~/go/bin' >> "$RC_FILE"
    fi

    source "$RC_FILE"
    print_success "Go-based tools installation complete."
}

install_go_tools
