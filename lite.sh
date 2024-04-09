#!/bin/bash

# Fungsi untuk menulis log saat status koneksi OFFLINE
write_offline_log() {
    echo "$(date +"%A %d %B %Y %T") Status: MATI $1" >> /etc/modem/log.txt
}

# Fungsi untuk menulis log saat status koneksi ONLINE
write_online_log() {
    echo "$(date +"%A %d %B %Y %T") Status: HIDUP" >> /etc/modem/log.txt
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

# Interval waktu antara penulisan log saat status koneksi OFFLINE (detik)
offline_log_interval=5

# Interval waktu antara penulisan log saat status koneksi ONLINE (detik)
online_log_interval=60

# Variabel untuk menentukan jumlah maksimum percobaan koneksi offline sebelum melakukan restart modem dan interface
max_retry=5

# Waktu awal untuk penulisan log saat status koneksi ONLINE
next_online_log_time=$(date +%s)

# Loop utama
while true; do
    # Waktu awal untuk pengecekan
    start_time=$(date +%s)
    
    # Cek koneksi internet dengan mengambil kode status HTTP
    http_code=$(curl -s -o /dev/null -w "%{http_code}" http://www.gstatic.com/generate_204)
    if [ $http_code -eq 204 ]; then
        # Jika kode status 204 (berarti koneksi online)
        offline_count=0
        if [ $(date +%s) -ge $next_online_log_time ]; then
            write_online_log
            next_online_log_time=$((next_online_log_time + online_log_interval))
        fi
    else
        # Jika kode status bukan 204 (berarti koneksi offline)
        ((offline_count++))
        write_offline_log "Failed $offline_count out of $max_retry"
        # Jika offline lebih dari jumlah maksimum percobaan
        if [ $offline_count -ge $max_retry ]; then
            write_offline_log "Failed $offline_count out of $max_retry > Action: Restart Modem"
            # Restart modem
            echo "at+cfun=1,1" > /dev/ttyACM2
            wait_seconds 10
            write_offline_log "Failed $offline_count out of $max_retry > Action: Restart Interface"
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
