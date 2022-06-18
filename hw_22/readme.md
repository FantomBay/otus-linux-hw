# Мосты, туннели и VPN.

Домашнее задание:

1. Между двумя виртуалками поднять vpn в режимах

    * tun;
    * tap; Прочуствовать разницу.

2.    Поднять RAS на базе OpenVPN с клиентскими сертификатами, подключиться с локальной машины на виртуалку. 3*. Самостоятельно изучить, поднять ocserv и подключиться с хоста к виртуалке Формат сдачи ДЗ - vagrant + ansible

--- 

Замер скорости для tap:
<details>
 <summary> Вывод 3-х замеров </summary>

    [root@client ~]# iperf3 -c 10.10.10.1 -t 40 -i 5
    Connecting to host 10.10.10.1, port 5201
    [  4] local 10.10.10.2 port 43764 connected to 10.10.10.1 port 5201
    [ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
    [  4]   0.00-5.00   sec  90.0 MBytes   151 Mbits/sec   70   1.29 KBytes       
    [  4]   5.00-10.01  sec  0.00 Bytes  0.00 bits/sec    1   1.29 KBytes       
    [  4]  10.01-15.00  sec  75.9 MBytes   128 Mbits/sec   55    537 KBytes       
    [  4]  15.00-20.00  sec   103 MBytes   173 Mbits/sec   25   1.29 KBytes       
    [  4]  20.00-25.01  sec  0.00 Bytes  0.00 bits/sec    2   1.29 KBytes       
    [  4]  25.01-30.01  sec  0.00 Bytes  0.00 bits/sec    1   1.29 KBytes       
    [  4]  30.01-35.00  sec  84.8 MBytes   142 Mbits/sec  225    386 KBytes       
    [  4]  35.00-40.01  sec  3.73 MBytes  6.26 Mbits/sec    4   1.29 KBytes       
    - - - - - - - - - - - - - - - - - - - - - - - - -
    [ ID] Interval           Transfer     Bandwidth       Retr
    [  4]   0.00-40.01  sec   358 MBytes  75.0 Mbits/sec  383             sender
    [  4]   0.00-40.01  sec   356 MBytes  74.5 Mbits/sec                  receiver

    iperf Done.
    [root@client ~]# iperf3 -c 10.10.10.1 -t 40 -i 5
    Connecting to host 10.10.10.1, port 5201
    [  4] local 10.10.10.2 port 43768 connected to 10.10.10.1 port 5201
    [ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
    [  4]   0.00-5.00   sec  61.7 MBytes   103 Mbits/sec   76   1.29 KBytes       
    [  4]   5.00-10.01  sec  0.00 Bytes  0.00 bits/sec    2   1.29 KBytes       
    [  4]  10.01-15.01  sec  0.00 Bytes  0.00 bits/sec    0   1.29 KBytes       
    [  4]  15.01-20.00  sec  42.5 MBytes  71.3 Mbits/sec   54   1.29 KBytes       
    [  4]  20.00-25.00  sec  0.00 Bytes  0.00 bits/sec    2   1.29 KBytes       
    [  4]  25.00-30.00  sec  79.8 MBytes   134 Mbits/sec  164   1.29 KBytes       
    [  4]  30.00-35.01  sec  0.00 Bytes  0.00 bits/sec    3   1.29 KBytes       
    [  4]  35.01-40.01  sec  0.00 Bytes  0.00 bits/sec    1   1.29 KBytes       
    - - - - - - - - - - - - - - - - - - - - - - - - -
    [ ID] Interval           Transfer     Bandwidth       Retr
    [  4]   0.00-40.01  sec   184 MBytes  38.6 Mbits/sec  302             sender
    [  4]   0.00-40.01  sec   181 MBytes  37.9 Mbits/sec                  receiver

    iperf Done.
    [root@client ~]# iperf3 -c 10.10.10.1 -t 40 -i 5
    Connecting to host 10.10.10.1, port 5201
    [  4] local 10.10.10.2 port 43772 connected to 10.10.10.1 port 5201
    [ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
    [  4]   0.00-5.00   sec  95.3 MBytes   160 Mbits/sec   13   1.29 KBytes       
    [  4]   5.00-10.00  sec  0.00 Bytes  0.00 bits/sec    2   1.29 KBytes       
    [  4]  10.00-15.01  sec  0.00 Bytes  0.00 bits/sec    1   1.29 KBytes       
    [  4]  15.01-20.00  sec  2.50 MBytes  4.20 Mbits/sec    1   1.10 MBytes       
    [  4]  20.00-25.01  sec  0.00 Bytes  0.00 bits/sec    0   1.10 MBytes       
    [  4]  25.01-30.01  sec  0.00 Bytes  0.00 bits/sec    0   1.10 MBytes       
    [  4]  30.01-35.00  sec  52.3 MBytes  87.8 Mbits/sec   74   1.29 KBytes       
    [  4]  35.00-40.01  sec  0.00 Bytes  0.00 bits/sec    3   1.29 KBytes       
    - - - - - - - - - - - - - - - - - - - - - - - - -
    [ ID] Interval           Transfer     Bandwidth       Retr
    [  4]   0.00-40.01  sec   150 MBytes  31.5 Mbits/sec   94             sender
    [  4]   0.00-40.01  sec   147 MBytes  30.9 Mbits/sec                  receiver

    iperf Done.     
    
</details>

средний результат по 3 замерам - tap:
```
sender - 75.0+38.6+31.5=145,1/3=48.36 Mbits/sec
receiver - 74.5+37.9+30.9=143,3/3=47.76 Mbits/sec
```

Замер скорости для tun:
<details>
 <summary> Вывод 3-х замеров </summary>

    [root@client ~]# iperf3 -c 10.10.10.1 -t 40 -i 5
    Connecting to host 10.10.10.1, port 5201
    [  4] local 10.10.10.2 port 43776 connected to 10.10.10.1 port 5201
    [ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
    [  4]   0.00-5.01   sec  18.3 MBytes  30.7 Mbits/sec   32   1.32 KBytes       
    [  4]   5.01-10.01  sec  0.00 Bytes  0.00 bits/sec    1   1.32 KBytes       
    [  4]  10.01-15.00  sec  9.79 MBytes  16.4 Mbits/sec   51    521 KBytes       
    [  4]  15.00-20.00  sec  50.8 MBytes  85.2 Mbits/sec    3   1.32 KBytes       
    [  4]  20.00-25.01  sec  0.00 Bytes  0.00 bits/sec    2   1.32 KBytes       
    [  4]  25.01-30.01  sec  0.00 Bytes  0.00 bits/sec    0   1.32 KBytes       
    [  4]  30.01-35.00  sec  9.06 MBytes  15.2 Mbits/sec    5   1.32 KBytes       
    [  4]  35.00-40.01  sec  0.00 Bytes  0.00 bits/sec    1   1.32 KBytes       
    --- - - - - - - - - - - - - - - - - - - - - - -
    [ ID] Interval           Transfer     Bandwidth       Retr
    [  4]   0.00-40.01  sec  87.9 MBytes  18.4 Mbits/sec   95             sender
    [  4]   0.00-40.01  sec  86.8 MBytes  18.2 Mbits/sec                  receiver

    iperf Done.
    [root@client ~]# iperf3 -c 10.10.10.1 -t 40 -i 5
    Connecting to host 10.10.10.1, port 5201
    [  4] local 10.10.10.2 port 43780 connected to 10.10.10.1 port 5201
    [ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
    [  4]   0.00-5.01   sec  3.90 MBytes  6.53 Mbits/sec    4   1.32 KBytes       
    [  4]   5.01-10.01  sec  0.00 Bytes  0.00 bits/sec    1   1.32 KBytes       
    [  4]  10.01-15.00  sec  23.8 MBytes  39.9 Mbits/sec  126   1.32 KBytes       
    [  4]  15.00-20.01  sec  0.00 Bytes  0.00 bits/sec    2   1.32 KBytes       
    [  4]  20.01-25.01  sec  0.00 Bytes  0.00 bits/sec    1   1.32 KBytes       
    [  4]  25.01-30.00  sec  68.0 MBytes   114 Mbits/sec   27    443 KBytes       
    [  4]  30.00-35.00  sec   146 MBytes   245 Mbits/sec    6    388 KBytes       
    [  4]  35.00-40.00  sec  56.9 MBytes  95.3 Mbits/sec    3   1.32 KBytes       
    - - - - - - - - - - - - - - - - - - - - - - - - -
    [ ID] Interval           Transfer     Bandwidth       Retr
    [  4]   0.00-40.00  sec   298 MBytes  62.5 Mbits/sec  170             sender
    [  4]   0.00-40.00  sec   298 MBytes  62.5 Mbits/sec                  receiver

    iperf Done.
    [root@client ~]# iperf3 -c 10.10.10.1 -t 40 -i 5
    Connecting to host 10.10.10.1, port 5201
    [  4] local 10.10.10.2 port 43784 connected to 10.10.10.1 port 5201
    [ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
    [  4]   0.00-5.01   sec  27.5 MBytes  46.1 Mbits/sec   26   1.32 KBytes       
    [  4]   5.01-10.01  sec  0.00 Bytes  0.00 bits/sec    1   1.32 KBytes       
    [  4]  10.01-15.01  sec  0.00 Bytes  0.00 bits/sec    0   1.32 KBytes       
    [  4]  15.01-20.00  sec  24.4 MBytes  41.0 Mbits/sec  396   1.32 KBytes       
    [  4]  20.00-25.00  sec  0.00 Bytes  0.00 bits/sec    1   1.32 KBytes       
    [  4]  25.00-30.00  sec  11.3 MBytes  18.9 Mbits/sec    7    398 KBytes       
    [  4]  30.00-35.00  sec  24.5 MBytes  41.1 Mbits/sec    4   1.32 KBytes       
    [  4]  35.00-40.01  sec  0.00 Bytes  0.00 bits/sec    1   1.32 KBytes       
    - - - - - - - - - - - - - - - - - - - - - - - - -
    [ ID] Interval           Transfer     Bandwidth       Retr
    [  4]   0.00-40.01  sec  87.7 MBytes  18.4 Mbits/sec  436             sender
    [  4]   0.00-40.01  sec  86.0 MBytes  18.0 Mbits/sec                  receiver

    iperf Done.


</details>

средний результат по 3 замерам - tun:
```
sender - 18.4+62.5+18.4=99.3/3=33.1 Mbits/sec
receiver - 18.2+62.5+18.0=98.7/3=32.9 Mbits/sec
```

По итогам замечено что у интерфейса типа - tap, скорость передачи данных чуть больше чем у tun.


>## Типы tun (L3сетевой ур-нь модели OSI) и tap (L2канальный OSI)
>__tun__  - нужен для объеденения 2-х локальных сетей в одну, условно общую, но с разной адресацией (192.168.20.0/24 и 192.168.40.0/24).  
>__tap__ - нужен для обединение 2-х удаленных сетей в единое адресное пространство (192.168.10.0/24)

