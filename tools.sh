#!/bin/bash

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

    MISSING_TOOLS=()
    for tool in "${APT_RECON_TOOLS[@]}"; do
        if ! dpkg-query -W -f='${Status}' "$tool" 2>/dev/null | grep -q "install ok installed"; then
            MISSING_TOOLS+=("$tool")
        else
            print_success "$tool is already installed."
        fi
    done

    if [ ${#MISSING_TOOLS[@]} -ne 0 ]; then
        print_status "Installing missing tools: ${MISSING_TOOLS[*]}"
        apt-get install -y "${MISSING_TOOLS[@]}"
    else
        print_success "All Recon and Bug Bounty tools are already installed."
    fi
    print_success "Recon and Bug Bounty tools installation via apt complete."
}

install_recon_bugbounty_tools
