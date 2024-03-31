#!/bin/sh

log_file="/www/antibengong/log.txt"
url_to_check="http://www.gstatic.com/generate_204"
offline_count=0

restart_modem_command="echo 'at+cfun=1,1' > /dev/ttyACM2"
restart_interface_command="ifdown mm && ifup mm"

while true; do
    timestamp=$(date +"%A %d %B %Y %T")
    http_code=$(curl -s -o /dev/null -w "%{http_code}" $url_to_check)
    if [ $http_code -eq 204 ]; then
        echo "$timestamp  Status: ONLINE" >> $log_file
        offline_count=0
    else
        echo "$timestamp  Status: OFFLINE" >> $log_file
        offline_count=$((offline_count + 1))
        if [ $offline_count -eq 5 ]; then
            echo "$timestamp  Status: Restart Modem & Interface" >> $log_file
            eval $restart_modem_command
            sleep 10 # Tambahkan penundaan setelah restart modem
            eval $restart_interface_command
            sleep 10 # Tambahkan penundaan setelah restart interface
            offline_count=0
        fi
    fi
    sleep 3
done
