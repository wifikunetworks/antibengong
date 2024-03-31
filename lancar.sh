#!/bin/bash

# Fungsi untuk menulis status koneksi ke file log.txt
write_log() {
    echo "$(date +"%A %d %B %Y %T")  Status: $1" >> /usr/antibengong/log.txt
}

# Fungsi untuk restart modem
restart_modem() {
    echo "Restarting modem..."
    echo "at+cfun=1,1" > /dev/ttyACM2
}

# Fungsi untuk restart interface modem
restart_modem_interface() {
    echo "Restarting modem interface..."
    ifdown mm && ifup mm
}

# Loop untuk pengecekan koneksi setiap 3 detik
while true; do
    # Cek koneksi internet dengan mengakses http://www.gstatic.com/generate_204
    wget -q --spider http://www.gstatic.com/generate_204

    # Periksa kode status HTTP dari permintaan sebelumnya
    if [ $? -eq 0 ]; then
        # Jika koneksi tersedia
        write_log "ONLINE"
    else
        # Jika koneksi tidak tersedia
        write_log "OFFLINE"
        # Tunggu 1 menit untuk memeriksa kembali koneksi sebelum melakukan restart
        sleep 57
        wget -q --spider http://www.gstatic.com/generate_204
        if [ $? -ne 0 ]; then
            # Jika koneksi masih tidak tersedia setelah 1 menit, restart modem
            restart_modem
            sleep 10  # Tunggu 10 detik setelah restart modem
            wget -q --spider http://www.gstatic.com/generate_204
            if [ $? -ne 0 ]; then
                # Jika koneksi masih tidak tersedia setelah restart modem, restart interface modem
                restart_modem_interface
            fi
        fi
    fi
    sleep 3  # Tunggu 3 detik sebelum memeriksa koneksi lagi
done
