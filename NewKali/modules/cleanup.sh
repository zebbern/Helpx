#!/bin/bash

cleanup() {
    print_status "Cleaning up unnecessary packages..."
    apt autoremove -y
    print_success "Cleanup complete."
}

cleanup
