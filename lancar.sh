#!/bin/bash

log_file="/usr/antibengong/log.txt"
modem_port="/dev/ttyACM2"
check_interval=3
offline_threshold=20 # 20 * 3 detik = 60 detik (1 menit)

restart_modem() {
    echo "Restarting modem..."
    echo "at+cfun=1,1" > "$modem_port"
    sleep 5
}

restart_modem_interface() {
    echo "Restarting modem interface..."
    ifdown mm && ifup mm
    sleep 5
}

check_internet_connection() {
    if wget -q --spider http://www.gstatic.com/generate_204; then
        echo "$(date +'%A %d %B %Y %T')  Status: ONLINE" >> "$log_file"
    else
        echo "$(date +'%A %d %B %Y %T')  Status: OFFLINE" >> "$log_file"
    fi
}

main() {
    while true; do
        check_internet_connection
        sleep $check_interval

        # Check if offline for more than 1 minute
        offline_count=$(grep -c "Status: OFFLINE" "$log_file")
        if [[ $offline_count -ge $offline_threshold ]]; then
            restart_modem
            restart_modem_interface
            echo "Internet connection restored after restarting modem and interface."
        fi
    done
}

main
