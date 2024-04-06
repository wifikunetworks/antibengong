JIKA BELUM ADA CONN MONITOR INSTALL TERLEBIH DAHULU

```
# INSTALL CONNECTION MONITOR
opkg remove --force-remove luci-app-lite-watchdog && rm /etc/modem/log.txt ; wget --no-check-certificate -P /root https://raw.githubusercontent.com/wifikunetworks/v1v2/main/luci-app-lite-watchdog_1.0.13-20231207_all.ipk && opkg install --force-reinstall /root/luci-*-watchdog*.ipk && rm /root/*.ipk
```

STABLE VERSION
```
# INSTALL ANTI BENGONG
wget --no-check-certificate -N -P /www/antibengong/ https://raw.githubusercontent.com/wifikunetworks/antibengong/main/lancar.sh && chmod +x /www/antibengong/lancar.sh
```

COMPLETE VERSION
```
# INSTALL ANTI BENGONG
wget --no-check-certificate -N -P /www/antibengong/ https://raw.githubusercontent.com/wifikunetworks/antibengong/main/final.sh && chmod +x /www/antibengong/final.sh
```

LITE VERSION
```
# INSTALL ANTI BENGONG
wget --no-check-certificate -N -P /www/antibengong/ https://raw.githubusercontent.com/wifikunetworks/antibengong/main/lite.sh && chmod +x /www/antibengong/lite.sh
```

TAMBAHKAN DI STARTUP RC.LOCAL
```
(sleep 60 && /www/antibengong/lancar.sh) &
```
```
(sleep 60 && /www/antibengong/final.sh) &
```
```
(sleep 60 && /www/antibengong/lite.sh) &
```
