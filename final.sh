#!/bin/bash

# Fungsi untuk menulis log
write_log() {
    echo "$(date +"%A %d %B %Y %T") Status: $1 $2" >> /etc/modem/log.txt
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

# Variabel untuk menentukan jumlah maksimum percobaan koneksi offline sebelum melakukan restart modem dan interface
max_retry=5

# Loop utama
while true; do
    # Waktu awal untuk pengecekan
    start_time=$(date +%s)
    
    # Cek koneksi internet dengan mengambil kode status HTTP
    http_code=$(curl -s -o /dev/null -w "%{http_code}" http://www.gstatic.com/generate_204)
    if [ $http_code -eq 204 ]; then
        # Jika kode status 204 (berarti koneksi online)
        write_log "HIDUP"
        # Reset offline count
        offline_count=0
    else
        # Jika kode status bukan 204 (berarti koneksi offline)
        ((offline_count++))
        write_log "MATI" "Failed $offline_count out of $max_retry"
        # Jika offline lebih dari jumlah maksimum percobaan
        if [ $offline_count -ge $max_retry ]; then
            write_log "OFFLINE" "Failed $offline_count out of $max_retry > Action: Restart Modem"
            # Restart modem
            echo "at+cfun=1,1" > /dev/ttyACM2
            wait_seconds 10
            write_log "OFFLINE" "Failed $offline_count out of $max_retry > Action: Restart Interface"
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
