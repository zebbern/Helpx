#!/bin/bash

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
        if ! pip3 show "$LIB" &>/dev/null; then
            print_status "Installing $LIB..."
            pip3 install "$LIB" || { print_error "Failed to install $LIB"; continue; }
            print_success "$LIB installed successfully."
        else
            print_success "$LIB is already installed."
        fi
    done
    print_success "Python libraries installation complete."
}

install_python_libraries
