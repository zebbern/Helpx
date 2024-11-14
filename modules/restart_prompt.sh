#!/bin/bash

prompt_restart() {
    echo
    echo "Would you like to restart now or later?"
    select RESTART in "Now" "Later"; do
        case $RESTART in
            "Now")
                print_status "System will restart now."
                reboot
                break
                ;;
            "Later")
                print_status "You can restart later. Setup is complete."
                break
                ;;
            *)
                echo "Invalid option. Please choose 1 or 2."
                ;;
        esac
    done
}

prompt_restart
