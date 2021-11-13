#!/bin/bash

file=$1
# Сколько строк в файле
    countRows=$(wc $file | awk '{print $1}')
    # Время начала и конца лог-файла
    periodFrom=$(awk '{print $4 $5}' $file | sed 's/\[//; s/\]//' | sed -n 1p)
    periodTo=$(awk '{print $4 $5}' $file | sed 's/\[//; s/\]//' | sed -n "$countRows"p)

    # Дата начала и конца
    # Определение количества IP запросов с IP адресов
    ips=$(awk '{print $1}' $file | uniq -c | sort -nrk 1 | awk 'BEGIN{print"№ count IP"}{print FNR,$1,$2}'| column -t)
    # Y количества адресов
    addresses=$(awk '($9 ~ /200/)' $file | awk '{print $7}' | sort | uniq -c | sort -rn | awk '{ if ( $1 >= 10 ) { print "Количество запросов:" $1, "URL:" $2 } }')
    # все ошибки c момента последнего запуска
    errors=$(cat $file | cut -d '"' -f3 | cut -d ' ' -f2 | sort | uniq -c | sort -rn)
    # Запись количества строк в файле
    
    # Отправка почты
    echo -e "Данные за период:$periodFrom-$periodTo\n$ips\n\n"Часто запрашиваемые адреса: "\n$addresses\n\n"Частые ошибки:"\n$errors" | mail -s "NGINX Log Info" root@localhost
