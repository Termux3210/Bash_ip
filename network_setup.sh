#!/bin/bash

if [ "$(id -u)" != "0" ]; then
    echo "Этот скрипт должен быть запущен с sudo или от имени root" 1>&2
    exit 1
fi

if [ "$#" -lt 1 ]; then
    echo "Использование: $0 <новый_ip_адрес> [маска_подсети] [шлюз]" 1>&2
    exit 1
fi

new_ip="$1"
subnet_mask="${2:-255.255.255.0}"
gateway="${3:-192.168.1.1}"

cp /etc/netplan/01-netcfg.yaml /etc/netplan/01-netcfg.yaml.bak

sed -i "s/address .*/address $new_ip/" /etc/netplan/01-netcfg.yaml

network_info=$(ip addr show)

echo "Текущая сетевая конфигурация:"
echo "$network_info"

echo -e "\nОтформатированная информация о сети:"
echo "$network_info" | awk '/inet / {print "Интерфейс:", $2, "\nIP-адрес:", $4, "\nМаска подсети:", $6, "\nШлюз:", $8}'

systemctl restart networking

if [ $? -eq 0 ]; then
    echo -e "\nКонфигурация сети успешно обновлена."
else
    echo -e "\nНе удалось обновить конфигурацию сети. Пожалуйста, проверьте настройки."
fi
