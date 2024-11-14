#!/bin/bash

setup_helpx() {
    print_status "Setting up 'helpx' command..."

    HELPTOPIC_DIR="/home/$ACTIVE_USER/.helptopics"
    sudo -u "$ACTIVE_USER" mkdir -p "$HELPTOPIC_DIR"

    # Create an example help topic if not exists
    if [ ! -f "$HELPTOPIC_DIR/waybackurls_grep.txt" ]; then
        sudo -u "$ACTIVE_USER" tee "$HELPTOPIC_DIR/waybackurls_grep.txt" > /dev/null <<'EOF'
# Waybackurls Grep Help
# ---------------------
# Edit hackerone.com to your URL
# Usage:
# waybackurls hackerone.com | grep -E --color '(\.xls|\.tar\.gz|\.bak|\.xml|\.xlsx|\.json|\.rar|\.pdf|\.sql|\.docx?|\.pptx|\.txt|\.zip|\.tgz|\.7z)$'

waybackurls hackerone.com | grep -E --color '(\.xls|\.tar\.gz|\.bak|\.xml|\.xlsx|\.json|\.rar|\.pdf|\.sql|\.docx?|\.pptx|\.txt|\.zip|\.tgz|\.7z)$'

# Example for OAuth2 Config Search
curl [yourdomain.com]/login?next=/ | grep -o '"oauth2Config": \[.*\]' | sed 's/"oauth2Config": //'
EOF
    fi

    # Create the helpx script in /usr/local/bin if not exists
    HELPX_SCRIPT="/usr/local/bin/helpx"
    if [ ! -f "$HELPX_SCRIPT" ]; then
        sudo tee "$HELPX_SCRIPT" > /dev/null <<'EOL'
#!/bin/bash

HELP_DIR="$HOME/.helptopics"

manage_cron_jobs() {
    echo "Cron Job Management"
    echo "-------------------"
    echo "1. View current cron jobs"
    echo "2. Add a new cron job"
    echo "3. Remove a cron job"
    echo "4. Exit"
    echo
    read -p "Enter your choice (1-4): " cron_choice

    case $cron_choice in
        1)
            echo "Current cron jobs:"
            crontab -l || echo "No cron jobs set."
            ;;
        2)
            read -p "Enter cron schedule (e.g., '0 2 * * *'): " cron_schedule
            read -p "Enter the command to run: " cron_command
            (crontab -l 2>/dev/null; echo "$cron_schedule $cron_command") | crontab -
            echo "Cron job added."
            ;;
        3)
            echo "Existing cron jobs:"
            crontab -l | nl
            read -p "Enter the cron job number to remove: " cron_num
            crontab -l | sed "${cron_num}d" | crontab -
            echo "Cron job #$cron_num removed."
            ;;
        4)
            echo "Exiting cron job management."
            ;;
        *)
            echo "Invalid choice. Please select between 1-4."
            ;;
    esac
}

if [[ "$1" == "-cron" ]]; then
    manage_cron_jobs
elif [[ "$1" == "create" ]]; then
    read -p "Enter topic name for help page (no spaces): " topic_name
    if [[ -z "$topic_name" ]]; then
        echo "Topic name cannot be empty."
        exit 1
    fi
    touch "$HELP_DIR/$topic_name.txt"
    echo "Help page '$topic_name' created. Please edit it with your content." > "$HELP_DIR/$topic_name.txt"
    echo "You can edit it using: nano $HELP_DIR/$topic_name.txt"
elif [[ -f "$HELP_DIR/$1.txt" ]]; then
    cat "$HELP_DIR/$1.txt"
elif [[ -z "$1" ]]; then
    echo "Helpx: Create, view, and manage help pages and cron jobs"
    echo "Usage:"
    echo "  helpx <topic>       - View a specific help topic"
    echo "  helpx create        - Create a new help topic"
    echo "  helpx -cron         - Manage cron jobs"
    echo
    echo "Available Help Topics:"
    for file in "$HELP_DIR"/*.txt; do
        [ -e "$file" ] || continue
        topic=$(basename "$file" .txt)
        echo "  - $topic"
    done
else
    echo "Help topic '$1' not found."
fi
EOL

        # Make helpx executable and set ownership
        chmod +x "$HELPX_SCRIPT"
        chown root:root "$HELPX_SCRIPT"
    else
        print_success "'helpx' script already exists."
    fi

    # Ensure /usr/local/bin is in PATH for active user
    if ! grep -q "/usr/local/bin" "$RC_FILE"; then
        echo 'export PATH=$PATH:/usr/local/bin' >> "$RC_FILE"
    fi

    # Apply changes
    source "$RC_FILE"

    print_success "'helpx' command setup complete. You can now use 'helpx' as a command."
}

setup_helpx
