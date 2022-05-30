Сценарии iptables
=================

Домашнее задание:


1. реализовать knocking port
    - centralRouter может попасть на ssh inetrRouter через knock скрипт пример в материалах.

2. добавить inetRouter2, который виден(маршрутизируется (host-only тип сети для виртуалки)) с хоста или форвардится порт через локалхост.
3. запустить nginx на centralServer.
4. пробросить 80й порт на inetRouter2 8080.
5. дефолт в инет оставить через inetRouter. Формат сдачи ДЗ - vagrant + ansible  
    - реализовать проход на 80й порт без маскарадинга  

---
1. Реальзовать knocking port
---

Требуется:
 - удаленная ВМ (жертва наших экспериметов)
 - iptabels
 - iptables-services
 - модуль iptables recent (обычно уже имеется в стандартном пакете iptables)

Решение:

На удаленном хосте, создаем длинное правило для iptables, в файле iptables.rules:
```
*filter
:INPUT DROP [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:TRAFFIC - [0:0]
:SSH-INPUT - [0:0]
:SSH-INPUTTWO - [0:0]

-A INPUT -j TRAFFIC
-A TRAFFIC -p icmp --icmp-type any -j ACCEPT
-A TRAFFIC -m state --state ESTABLISHED,RELATED -j ACCEPT
-A TRAFFIC -m state --state NEW -m tcp -p tcp --dport 22 -m recent --rcheck --seconds 30 --name SSH2 -j ACCEPT
-A TRAFFIC -m state --state NEW -m tcp -p tcp -m recent --name SSH2 --remove -j DROP
-A TRAFFIC -m state --state NEW -m tcp -p tcp --dport 9991 -m recent --rcheck --name SSH1 -j SSH-INPUTTWO
-A TRAFFIC -m state --state NEW -m tcp -p tcp -m recent --name SSH1 --remove -j DROP
-A TRAFFIC -m state --state NEW -m tcp -p tcp --dport 7777 -m recent --rcheck --name SSH0 -j SSH-INPUT
-A TRAFFIC -m state --state NEW -m tcp -p tcp -m recent --name SSH0 --remove -j DROP
-A TRAFFIC -m state --state NEW -m tcp -p tcp --dport 8881 -m recent --name SSH0 --set -j DROP
-A SSH-INPUT -m recent --name SSH1 --set -j DROP
-A SSH-INPUTTWO -m recent --name SSH2 --set -j DROP
-A TRAFFIC -j DROP
COMMIT
```

После этого внесем правило в таблицу и сохраним изменения:
```
systemctl start iptables
systemctl enable iptables
iptables-restore < iptables.rules
service iptables save
```


У себя создадим скрипт, которым будем "стучаться" nmap-ом на удаленный хост:
```bash
#!/bin/bash
HOST=$1
shift
for ARG in "$@"
do
    sudo nmap -Pn --max-retries 0 -p $ARG $HOST
done
```

Запустим его:
```
chmod + x knock.sh && ./knock.sh 192.168.60.10 8881 7777 9991
```

После этого у нас имеется ~30 секунд для подключения (в течении ~30 секунд порт будет открыт для того(ip), c которого правильно постучались).

<details>
 <summary> Вывод </summary>
  ```
  long console output here
  ```
</details>

---
2. добавить inetRouter2, который виден(маршрутизируется (host-only тип сети для виртуалки)) с хоста или форвардится порт через локалхост.
---

Требуется:
 - 2 ВМ  

Решение:  

На 1 ВМ включим проброс портов (forwarding ports) на уровне ядра:

```bash
$ echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
```

Что бы настройка сохранилась после перезагрузки, изменим параметр ядра:
```bash
sudo sysctl -w net.ipv4.ip_forward=1
```
Для проброcа пакетов через хост имеется цепочка FORWARD:
```
sudo iptables -A FORWARD -i eth0 -o eth1 -p tcp --syn --dport 80 -m conntrack --ctstate NEW -j ACCEPT
```

<details>
 <summary> Вывод </summary>
  
  ```
  long console output here
  ```
  
</details>
