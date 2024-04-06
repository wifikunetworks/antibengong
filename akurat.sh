#!/bin/bash

# Fungsi untuk menulis log
write_log() {
    echo "$(date +"%A %d %B %Y %T") Status: $1" >> /www/antibengong/log.txt
}

# Fungsi untuk menunggu selama waktu yang ditentukan
wait_seconds() {
    local end_time=$(( $(date +%s) + $1 ))
    while [ $(date +%s) -lt $end_time ]; do
        sleep 1
    done
}

# Inisialisasi jumlah status offline berturut-turut
offline_count=0

# Interval waktu antara setiap pengecekan (detik)
check_interval=5

# Loop utama
while true; do
    # Waktu awal untuk pengecekan
    start_time=$(date +%s)
    
    # Cek koneksi internet dengan mengambil kode status HTTP
    http_code=$(curl -s -o /dev/null -w "%{http_code}" http://www.gstatic.com/generate_204)
    if [ $http_code -eq 204 ]; then
        # Jika kode status 204 (berarti koneksi online)
        write_log "ONLINE"
        # Reset offline count
        offline_count=0
    else
        # Jika kode status bukan 204 (berarti koneksi offline)
        write_log "OFFLINE"
        ((offline_count++))
        # Jika offline lebih dari 5 kali berturut-turut, restart modem dan interface
        if [ $offline_count -ge 5 ]; then
            write_log "Restart Modem & Interface"
            # Restart modem
            echo "at+cfun=1,1" > /dev/ttyACM2
            wait_seconds 10
            # Restart interface modem
            ifdown mm && sleep 5 && ifup mm
            wait_seconds 10
            # Reset offline count
            offline_count=0
        fi
    fi
    
    # Waktu akhir untuk pengecekan
    end_time=$(date +%s)
    
    # Hitung sisa waktu sebelum melakukan pengecekan berikutnya
    remaining_time=$((check_interval - (end_time - start_time)))
    
    # Tunggu hingga waktunya untuk melakukan pengecekan berikutnya
    while [ $remaining_time -gt 0 ]; do
        sleep 1
        remaining_time=$((remaining_time - 1))
    done
done
