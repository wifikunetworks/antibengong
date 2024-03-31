#!/bin/bash

# Path untuk log file
LOG_FILE="/usr/bin/antibengong/log.txt"

# URL untuk dicek koneksi internet
CHECK_URL="http://www.gstatic.com/generate_204"

# Waktu interval pengecekan (dalam detik)
CHECK_INTERVAL=3

# Waktu maksimum tanpa koneksi sebelum restart (dalam detik)
MAX_OFFLINE_TIME=60

# Fungsi untuk menulis log
write_log() {
    echo "$(date '+%A %d %B %Y %H:%M:%S')  Status: $1" >> "$LOG_FILE"
}

# Fungsi untuk merestart modem
restart_modem() {
    echo "Restarting modem..."
    # Ganti perintah berikut dengan perintah yang benar untuk merestart modem
    # contoh: at+cfun=1,1 -p /dev/ttyACM2
    at+cfun=1,1 -p /dev/ttyACM2
}

# Fungsi untuk merestart interface modem
restart_modem_interface() {
    echo "Restarting modem interface..."
    # Ganti perintah berikut dengan perintah yang benar untuk merestart interface modem
    # contoh: ifdown mm && ifup mm
    ifdown mm && ifup mm
}

# Fungsi untuk memeriksa koneksi internet
check_internet_connection() {
    wget -q --spider "$CHECK_URL"
    return $?
}

# Main loop
while true; do
    if check_internet_connection; then
        write_log "ONLINE"
    else
        write_log "OFFLINE"
        offline_time=0

        # Cek waktu offline
        while [ "$offline_time" -lt "$MAX_OFFLINE_TIME" ]; do
            sleep "$CHECK_INTERVAL"
            offline_time=$((offline_time + CHECK_INTERVAL))
            if check_internet_connection; then
                write_log "ONLINE"
                break
            fi
        done

        # Jika waktu offline sudah mencapai batas maksimum, restart modem atau interface modem
        if [ "$offline_time" -ge "$MAX_OFFLINE_TIME" ]; then
            restart_modem
            restart_modem_interface
        fi
    fi

    sleep "$CHECK_INTERVAL"
done
