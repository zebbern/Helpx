#!/bin/bash

# -----------------------------
# Helpx: Help and Cron Job Management Tool
# -----------------------------

# -----------------------------
# Exit on any error and treat unset variables as errors
# -----------------------------
set -euo pipefail

# -----------------------------
# Define Known Commands Globally
# -----------------------------
# Added "list" to known_commands
known_commands=("create" "edit" "delete" "list" "menu" "gui")

# -----------------------------
# Function to Check if Script is Sourced
# -----------------------------
is_sourced() {
    # Check if the script is being sourced
    # BASH_SOURCE[0] != $0 when sourced
    [[ "${BASH_SOURCE[0]}" != "${0}" ]]
}

# -----------------------------
# Function to Define Colors for Output
# -----------------------------
define_colors() {
    HELPX_RED='\033[0;31m'
    HELPX_GREEN='\033[0;32m'
    HELPX_BLUE='\033[0;34m'
    HELPX_YELLOW='\033[1;33m'
    HELPX_CYAN='\033[0;36m'
    HELPX_RESET='\033[0m'
}

# Initialize Colors
define_colors

# -----------------------------
# Function to Print Header
# -----------------------------
print_header() {
    echo -e "${HELPX_CYAN}"
    echo "=============================="
    echo "          HELPX MENU          "
    echo "=============================="
    echo -e "${HELPX_RESET}"
}

# -----------------------------
# Helper Functions for Output
# -----------------------------
print_success() {
    echo -e "${HELPX_GREEN}[+] $1${HELPX_RESET}"
}

print_error() {
    echo -e "${HELPX_RED}[-] $1${HELPX_RESET}"
}

print_info() {
    echo -e "${HELPX_YELLOW}[i] $1${HELPX_RESET}"
}

print_prompt() {
    echo -e "${HELPX_BLUE}[*] $1${HELPX_RESET}"
}
print_color() {
    echo -e "${HELPX_GREEN}[-] $1${HELPX_RESET}"
}

# -----------------------------
# Function to Determine Home Directory
# -----------------------------
determine_home() {
    if [[ "$EUID" -eq 0 && -n "${SUDO_USER:-}" ]]; then
        # Get the home directory of the user who invoked sudo
        USER_HOME=$(eval echo "~$SUDO_USER")
    else
        USER_HOME="$HOME"
    fi
    echo "$USER_HOME"
}

# -----------------------------
# Function to Define Help Topics Directory
# -----------------------------
define_help_dir() {
    USER_HOME=$(determine_home)
    HELP_DIR="$USER_HOME/.helptopics"
    mkdir -p "$HELP_DIR"
}

# -----------------------------
# Define Log File
# -----------------------------
define_log_file() {
    LOG_FILE="$HELP_DIR/.helpx.log"
    if [[ ! -f "$LOG_FILE" ]]; then
        touch "$LOG_FILE"
        chmod 664 "$LOG_FILE"
    fi
}

# -----------------------------
# Function to Log Actions
# -----------------------------
log_action() {
    local action="$1"
    local detail="$2"
    echo "$(date '+%Y-%m-%d %H:%M:%S') : $action : $detail" >> "$LOG_FILE"
}

# -----------------------------
# Function to Sanitize Topic Names (Auto-formatting)
# -----------------------------
sanitize_topic_name() {
    local raw_name="$1"
    # Replace spaces with underscores, remove trailing .txt, and remove invalid characters
    local sanitized_name
    sanitized_name=$(echo "$raw_name" | sed 's/\.txt$//' | tr ' ' '_' | tr -cd '[:alnum:]_-')
    echo "$sanitized_name"
}

# -----------------------------
# Function to Use User's Default Editor
# -----------------------------
get_editor() {
    local editor
    editor="${EDITOR:-nano}"
    echo "$editor"
}

# -----------------------------
# Function to Install Helpx as Command-Line Tool
# -----------------------------
install_helpx() {
    # Define the installation path
    local install_path="/usr/local/bin/helpx"

    # Check if helpx is already installed
    if command -v helpx &>/dev/null; then
        print_info "Existing helpx installation found at $(command -v helpx). Overwriting..."
        sudo rm -f "$install_path"
    fi

    # Install the new helpx script
    sudo cp "$(realpath "${BASH_SOURCE[0]}")" "$install_path"
    sudo chmod +x "$install_path"
    sudo chown root:root "$install_path"

    print_success "Helpx installed successfully at $install_path."
    log_action "INSTALL" "Helpx installed at $install_path."
}

# -----------------------------
# Function to Create a New Help Topic
# -----------------------------
create_topic() {
    local raw_topic_name="$1"
    # Removed category parameter as per user request

    if [[ -z "$raw_topic_name" ]]; then
        print_error "Please provide a topic name. Usage: helpx create <topic_name>"
        exit 1
    fi

    # Sanitize topic name
    local topic_name
    topic_name=$(sanitize_topic_name "$raw_topic_name")

    # Define topic file path directly in HELP_DIR
    local topic_file="$HELP_DIR/$topic_name.txt"

    if [[ -f "$topic_file" ]]; then
        print_error "Help topic '$topic_name.txt' already exists."
        exit 1
    fi

    # Create the topic with a template
    tee "$topic_file" > /dev/null <<'EOF'
# <Topic Name> Help
# ---------------------
# Description:
# Tags: 
# Usage:
# Examples:
EOF

    print_success "Help topic '$topic_name' created successfully."
    log_action "CREATE" "Topic '$topic_name' created."

    # Open the topic in the default editor
    local editor
    editor=$(get_editor)
    "$editor" "$topic_file"
}

# -----------------------------
# Function to Edit an Existing Help Topic
# -----------------------------
edit_topic() {
    local topic_name="$1"

    if [[ -z "$topic_name" ]]; then
        print_error "Please provide a topic name. Usage: helpx edit <topic_name>"
        exit 1
    fi

    # Strip .txt if present to prevent double extension
    topic_name="${topic_name%.txt}"  # # CHANGE

    # Find the topic file using exact path
    local topic_file
    topic_file="$HELP_DIR/$topic_name.txt"

    if [[ ! -f "$topic_file" ]]; then
        print_error "Help topic '$topic_name.txt' does not exist."
        exit 1
    fi

    print_header
    echo -e "${HELPX_GREEN}Editing Help Topic: $topic_name${HELPX_RESET}"
    echo "----------------------------------------"

    # Backup the current topic before editing
    cp "$topic_file" "$topic_file.bak"
    print_info "Backup created at '$topic_file.bak'."
    log_action "BACKUP" "Backup created for topic '$topic_name'."

    # Open the topic in the default editor
    local editor
    editor=$(get_editor)
    "$editor" "$topic_file"

    print_success "Help topic '$topic_name' updated successfully."
    log_action "EDIT" "Topic '$topic_name' edited."
}

# -----------------------------
# Function to Delete a Help Topic
# -----------------------------
delete_topic() {
    local topic_name="$1"

    if [[ -z "$topic_name" ]]; then
        print_error "Please provide a topic name. Usage: helpx delete <topic_name>"
        exit 1
    fi

    # Strip .txt if present to prevent double extension
    topic_name="${topic_name%.txt}"  # # CHANGE

    # Find the topic file using exact path
    local topic_file
    topic_file="$HELP_DIR/$topic_name.txt"

    if [[ ! -f "$topic_file" ]]; then
        print_error "Help topic '$topic_name.txt' does not exist."
        exit 1
    fi

    # Backup before deletion
    cp "$topic_file" "$topic_file.bak"
    print_info "Backup created at '$topic_file.bak'."
    log_action "BACKUP_DELETE" "Backup created before deleting topic '$topic_name'."

    rm "$topic_file"
    print_success "Help topic '$topic_name' deleted successfully."
    log_action "DELETE" "Topic '$topic_name' deleted."
}

# -----------------------------
# Function to List All Help Topics
# -----------------------------
list_topics() {
    echo -e "${HELPX_CYAN}"
    echo "LIST OF HELP TOPICS"
    echo "========================================"
    echo -e "${HELPX_RESET}"

    # Check if HELP_DIR exists and is not empty
    if [[ -d "$HELP_DIR" ]]; then
        local topics=("$HELP_DIR"/*.txt)
        
        if [[ -e "${topics[0]}" ]]; then
            for topic_file in "${topics[@]}"; do
                # Extract the filename without the directory and .txt extension
                local filename
                filename=$(basename "$topic_file" .txt)
                echo "- $filename"
            done
            log_action "LIST" "Listed all help topics."
        else
            echo -e "${HELPX_YELLOW}No help topics found.${HELPX_RESET}"
        fi
    else
        echo -e "${HELPX_YELLOW}Help topics directory does not exist.${HELPX_RESET}"
    fi
}

# -----------------------------
# Function to Implement Interactive Menu Using select
# -----------------------------
interactive_menu() {
    while true; do
        print_header
        echo -e "${HELPX_YELLOW}Interactive Helpx Menu:${HELPX_RESET}"
        echo "1. Create a New Help Topic"
        echo "2. Edit an Existing Help Topic"
        echo "3. Delete a Help Topic"
        echo "4. List All Help Topics"
        echo "5. Exit"
        echo

        read -p "Enter your choice (1-5): " choice

        case "$choice" in
            1)
                read -p "Enter the new topic name: " raw_topic_name
                [[ -z "$raw_topic_name" ]] && print_error "Topic name cannot be empty." && continue
                create_topic "$raw_topic_name"
                ;;
            2)
                read -p "Enter the topic name to edit: " topic_name
                [[ -z "$topic_name" ]] && print_error "Topic name cannot be empty." && continue
                edit_topic "$topic_name"
                ;;
            3)
                read -p "Enter the topic name to delete: " topic_name
                [[ -z "$topic_name" ]] && print_error "Topic name cannot be empty." && continue
                # Confirmation Prompt
                read -p "Are you sure you want to delete '$topic_name'? (y/N): " confirm
                case "$confirm" in
                    [yY][eE][sS]|[yY])
                        delete_topic "$topic_name"
                        ;;
                    *)
                        print_info "Deletion cancelled."
                        ;;
                esac
                ;;
            4)
                list_topics
                ;;
            5)
                print_info "Exiting Interactive Menu."
                break
                ;;
            *)
                print_error "Invalid choice. Please select between 1-5."
                ;;
        esac
        echo
    done
}

# -----------------------------
# Function to Implement GUI Menu Using Zenity
# -----------------------------
gui_menu() {
    while true; do
        # Display the main menu using Zenity and suppress GTK warnings
        selection=$(zenity --list --title="Helpx GUI Menu" \
            --column="Options" \
            "Create a New Help Topic" \
            "Edit an Existing Help Topic" \
            "Delete a Help Topic" \
            "List All Help Topics" \
            "Exit" \
            --height=500 --width=500 2>/dev/null)

        # Check if the user closed the dialog
        if [[ $? -ne 0 ]]; then
            break
        fi

        case "$selection" in
            "Create a New Help Topic")
                # Prompt for topic name
                raw_topic_name=$(zenity --entry --title="Create Help Topic" --text="Enter the new topic name:" 2>/dev/null)

                # Check if user canceled or entered nothing
                if [[ $? -ne 0 || -z "$raw_topic_name" ]]; then
                    zenity --warning --text="Topic creation canceled or no name entered." 2>/dev/null
                    continue
                fi

                # Sanitize topic name
                sanitized_topic_name=$(sanitize_topic_name "$raw_topic_name")

                # Create the topic
                create_topic "$raw_topic_name"
                ;;
            "Edit an Existing Help Topic")
                # Get list of topics
                topics=$(find "$HELP_DIR" -type f -name "*.txt" | sed "s|$HELP_DIR/||;s|\.txt$||" | sort)

                if [[ -z "$topics" ]]; then
                    zenity --error --text="No help topics available to edit." 2>/dev/null
                    continue
                fi

                # Prompt to select a topic
                topic_name=$(zenity --list --title="Edit Help Topic" --column="Topics" $topics 2>/dev/null)

                if [[ $? -ne 0 || -z "$topic_name" ]]; then
                    zenity --warning --text="No topic selected for editing." 2>/dev/null
                    continue
                fi

                # Edit the selected topic
                edit_topic "$topic_name"
                ;;
            "Delete a Help Topic")
                # Get list of topics
                topics=$(find "$HELP_DIR" -type f -name "*.txt" | sed "s|$HELP_DIR/||;s|\.txt$||" | sort)

                if [[ -z "$topics" ]]; then
                    zenity --error --text="No help topics available to delete." 2>/dev/null
                    continue
                fi

                # Prompt to select a topic
                topic_name=$(zenity --list --title="Delete Help Topic" --column="Topics" $topics 2>/dev/null)

                if [[ $? -ne 0 || -z "$topic_name" ]]; then
                    zenity --warning --text="No topic selected for deletion." 2>/dev/null
                    continue
                fi

                # Confirmation
                zenity --question --title="Confirm Deletion" --text="Are you sure you want to delete '$topic_name'?" 2>/dev/null

                if [[ $? -eq 0 ]]; then
                    delete_topic "$topic_name"
                else
                    zenity --info --text="Deletion cancelled." 2>/dev/null
                fi
                ;;
            "List All Help Topics")
                # Create a temporary file to store the list
                tmpfile=$(mktemp)

                # Capture the list of topics
                list_topics > "$tmpfile"

                # Display the list using Zenity
                zenity --text-info --title="List of Help Topics" --filename="$tmpfile" --width=400 --height=400 2>/dev/null

                # Remove the temporary file
                rm -f "$tmpfile"
                ;;
            "Exit")
                print_info "Exiting GUI Menu."
                break
                ;;
            *)
                print_error "Invalid selection."
                ;;
        esac
    done
}


# -----------------------------
# Function to Install or Update Helpx (Only when Sourced)
# -----------------------------
install_or_update_helpx() {
    install_helpx
}


define_help_dir
define_log_file


view_topic_console() {
    local topic_name="$1"

    if [[ -z "$topic_name" ]]; then
        print_error "Please provide a topic name. Usage: helpx \"topic_name\""
        exit 1
    fi

    # Strip .txt if present to prevent double extension
    topic_name="${topic_name%.txt}"  # # CHANGE

    # Find the topic file using exact path
    local topic_file
    topic_file="$HELP_DIR/$topic_name.txt"

    if [[ ! -f "$topic_file" ]]; then
        print_error "Help topic '$topic_name.txt' does not exist."
        exit 1
    fi

    print_header
    echo -e "${HELPX_YELLOW}Help Topic: $topic_name${HELPX_RESET}"
    echo "----------------------------------------"
    cat "$topic_file"
    echo "----------------------------------------"

    log_action "VIEW_CONSOLE" "Viewed topic '$topic_name' in console."
}

# -----------------------------
# Main Execution (Only when not Sourced)
# -----------------------------
if ! is_sourced; then
    # known_commands are already defined globally

    # If exactly one argument
    if [[ $# -eq 1 ]]; then
        # Check if the argument is a known command
        if [[ " ${known_commands[@]} " =~ " $1 " ]]; then
            # It's a known command, handle accordingly
            case "${1}" in
                create)
                    # Missing topic name
                    print_error "Please provide a topic name. Usage: helpx create <topic_name>"
                    exit 1
                    ;;
                edit)
                    print_error "Please provide a topic name. Usage: helpx edit <topic_name>"
                    exit 1
                    ;;
                delete)
                    print_error "Please provide a topic name. Usage: helpx delete <topic_name>"
                    exit 1
                    ;;
                list)
                    list_topics
                    ;;
                menu)
                    interactive_menu
                    ;;
                gui)
                    gui_menu
                    ;;
                *)
                    # Removed handling for "search", "cron", "help"
                    print_error "Invalid command."
                    exit 1
                    ;;
            esac
            exit 0
        else
            # Treat as topic name (including category, but categories are not used)
            view_topic_console "$1"
            exit 0
        fi
    fi

    # Handle multiple arguments or other commands
    case "${1:-}" in
        create)
            if [[ -z "${2:-}" ]]; then
                print_error "Please provide a topic name. Usage: helpx create <topic_name>"
                exit 1
            fi
            create_topic "$2"
            ;;
        edit)
            if [[ -z "${2:-}" ]]; then
                print_error "Please provide a topic name. Usage: helpx edit <topic_name>"
                exit 1
            fi
            edit_topic "$2"
            ;;
        delete)
            if [[ -z "${2:-}" ]]; then
                print_error "Please provide a topic name. Usage: helpx delete <topic_name>"
                exit 1
            fi
            delete_topic "$2"
            ;;
        list)
            list_topics
            ;;
        menu)
            interactive_menu
            ;;
        gui)
            gui_menu
            ;;
        *)
            # Removed handling for "search", "cron", "help"
print_color "      𝙎𝙮𝙣𝙩𝙖𝙭 𝙈𝙞𝙨𝙨𝙞𝙣𝙜         "
print_error " •═════════|══════════•      "
print_error " •         V          •      "
print_error " •  ╭──────────────╮  •       "
print_error " •  │    Menu      │  •       "
print_error " •  ╰──────────────╯  •       "
print_error " •  ╭──────────────╮  •       "
print_error " •  │     Gui      │  •       "
print_error " •  ╰──────────────╯  •       "
print_error " •  ╭──────────────╮  •       "
print_error " •  │    List      │  •       "
print_error " •  ╰──────────────╯  •       "
print_error " •  ╭──────────────╮  •       "
print_error " •  │   Delete     │  •       "
print_error " •  ╰──────────────╯  •       "
print_error " •════════════════════•       "
print_color "   𝙜𝙞𝙩𝙝𝙪𝙗.𝙘𝙤𝙢/𝙯𝙚𝙗𝙗𝙚𝙧𝙣        "


            exit 1
            ;;
    esac
fi

exit 0
