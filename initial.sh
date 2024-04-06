#!/bin/bash

# Fungsi untuk menulis log
write_log() {
    echo "$(date +"%A %d %B %Y %T") Status: $1" >> /www/antibengong/log.txt
}

# Inisialisasi jumlah status offline berturut-turut
offline_count=0

# Loop utama
while true; do
    # Cek koneksi internet
    if wget -q --spider http://www.gstatic.com/generate_204; then
        # Jika koneksi online
        write_log "ONLINE"
        # Reset offline count
        offline_count=0
    else
        # Jika koneksi offline
        write_log "OFFLINE"
        ((offline_count++))
        # Jika offline lebih dari 10 kali berturut-turut, restart modem dan interface
        if [ $offline_count -ge 10 ]; then
            write_log "Restart Modem & Interface"
            # Restart modem
            echo "at+cfun=1,1" > /dev/ttyACM2
            # Restart interface modem
            ifdown mm && sleep 5 && ifup mm
            # Reset offline count
            offline_count=0
        fi
    fi
    # Tunggu 5 detik
    sleep 5
done
