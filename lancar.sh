#!/bin/bash

# Path to log file
LOG_FILE="/usr/bin/antibengong/log.txt"

# Function to log status
log_status() {
    echo "$(date +"%A %d %B %Y %T")  Status: $1" >> "$LOG_FILE"
}

# Function to restart modem
restart_modem() {
    echo "Restarting modem..."
    # Command to restart modem
    echo "AT+CFUN=1,1" > /dev/ttyACM2
}

# Function to restart modem interface
restart_modem_interface() {
    echo "Restarting modem interface..."
    # Command to restart modem interface
    /sbin/ifdown mm && /sbin/ifup mm
}

# Main loop
while true; do
    # Check internet connectivity
    if wget -q --spider http://www.gstatic.com/generate_204; then
        log_status "ONLINE"
    else
        log_status "OFFLINE"
        # Restart modem and interface
        log_status "OFFLINE - Restarting modem and interface..."
        restart_modem
        sleep 5
        restart_modem_interface
    fi
    # Wait for 3 seconds before the next check
    sleep 3
done
