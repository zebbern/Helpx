#!/bin/bash

setup_nuclei_auto_update() {
    print_status "Setting up Nuclei templates auto-updater (cron job)..."
    if command -v nuclei &>/dev/null; then
        NUCLEI_PATH=$(command -v nuclei)
        CRON_JOB="0 2 * * * $NUCLEI_PATH -update-templates"
        # Check if cron job already exists
        crontab -u "$ACTIVE_USER" -l 2>/dev/null | grep -Fq "$CRON_JOB" && echo "Cron job already exists." || (crontab -u "$ACTIVE_USER" -l 2>/dev/null; echo "$CRON_JOB") | crontab -u "$ACTIVE_USER" -
        print_success "Nuclei templates auto-updater scheduled."
    else
        print_error "Nuclei is not installed. Cannot set up auto-updater."
    fi
}

setup_nuclei_auto_update
