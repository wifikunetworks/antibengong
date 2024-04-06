#!/bin/bash

# Fungsi untuk menulis log
write_log() {
    echo "$(date +"%A %d %B %Y %T")  Status: $1 $2" >> /etc/modem/log.txt
}

# Fungsi untuk menunggu hingga menit berikutnya
wait_next_minute() {
    local current_minute
    current_minute=$(date +"%M")
    while [ "$(date +"%M")" = "$current_minute" ]; do
        sleep 1
    done
}

# Inisialisasi jumlah status offline berturut-turut
offline_count=0

# Interval waktu antara setiap pengecekan (detik)
check_interval=5

# Variabel untuk menentukan jumlah maksimum percobaan koneksi offline sebelum melakukan restart modem dan interface
max_retry=5

# Waktu awal untuk penulisan log
next_log_minute=$(date +"%M")

# Loop utama
while true; do
    # Cek apakah sudah waktunya untuk menulis log
    if [ "$(date +"%M")" = "$next_log_minute" ]; then
        # Waktu awal untuk pengecekan
        start_time=$(date +%s)
        
        # Cek koneksi internet dengan mengambil kode status HTTP
        http_code=$(curl -s -o /dev/null -w "%{http_code}" http://www.gstatic.com/generate_204)
        if [ $http_code -eq 204 ]; then
            # Jika kode status 204 (berarti koneksi online)
            offline_count=0
            write_log "ONLINE"
        else
            # Jika kode status bukan 204 (berarti koneksi offline)
            ((offline_count++))
            write_log "OFFLINE" "Failed $offline_count out of $max_retry"
            # Jika offline lebih dari jumlah maksimum percobaan
            if [ $offline_count -ge $max_retry ]; then
                write_log "OFFLINE" "Failed $offline_count out of $max_retry > Action: Restart Modem"
                # Restart modem
                echo "at+cfun=1,1" > /dev/ttyACM2
                sleep 10
                write_log "OFFLINE" "Failed $offline_count out of $max_retry > Action: Restart Interface"
                # Restart interface modem
                ifdown mm && ifup mm
                sleep 10
                # Reset offline count
                offline_count=0
            fi
        fi
        
        # Waktu akhir untuk pengecekan
        end_time=$(date +%s)
        
        # Tunggu hingga menit berikutnya untuk pengecekan selanjutnya
        wait_next_minute
        
        # Perbarui waktu untuk penulisan log selanjutnya
        next_log_minute=$(date +"%M")
    else
        # Tunggu 1 detik sebelum melakukan pengecekan berikutnya
        sleep 1
    fi
done
