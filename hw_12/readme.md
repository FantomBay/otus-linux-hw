# Systemd (Centos8 Stream)

1. Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова (файл лога и ключевое слово должны задаваться в /etc/sysconfig).
2. Из репозитория epel установить spawn-fcgi и переписать init-скрипт на unit-файл (имя service должно называться так же: spawn-fcgi).
3. Дополнить unit-файл httpd (он же apache) возможностью запустить несколько инстансов сервера с разными конфигурационными файлами.  

4*. Скачать демо-версию Atlassian Jira и переписать основной скрипт запуска на unit-файл.

---

### 1. Написать service, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого слова (файл лога и ключевое слово должны задаваться в /etc/sysconfig).




- Создадим файл конфигурации для нашего севиса, где будет задано __ключевое слово__ и __файл лога__ ```vim /etc/sysconfig/keys``` :

```
WORD="ALERT"
LOG="/var/log/test.log" 
```

- Создадим лог-файл ```vi /var/log/test.log```, и добавим туда наше ключевое слово ```ALERT```:

```
test
1234123
ALERT
caps
123
ALERT
53
ggrw
```

Создаем скрипт ```vi /opt/myscript.sh```:

```
#!/bin/bash
WORD=$1
LOG=$2
DATE=`date`
if grep $WORD $LOG &> /dev/null
then
logger "$DATE: I found word, Master!" # logger отправляет лог в системный журнал (/var/log/messages)
else
exit 0
fi
```

*делаем его исполняемым```chmod +x /opt/watchlog.sh```.

- Далее создадим сам unit в ```vi /etc/systemd/system/watchlog.service```: 

```
[Unit]
Description=My watchlog service

[Service]
Type=oneshot
EnvironmentFile=/etc/sysconfig/keys
ExecStart=/opt/myscript.sh $WORD $LOG
```

- далее содадим unit для таймера ```vi /etc/systemd/system/watchlog.timer```:

```
[Unit]
Description=Run myscript.sh every 30 second

[Timer]
# Run every 30 second:
OnUnitActiveSec=30
# Name runing service:
Unit=watchlog.service

[Install]
WantedBy=timer.target
```

- выставим права сервису и его таймеру:

```
chmod 644 /etc/systemd/system/watchlog.*
```

- перечитаем файлы systemd: 

```
systemctl daemon-reload
```

- запускаем ~~наше детище~~: 
```
systemctl start watchlog.timer
``` 

```
systemctl start watchlog.service
```

> ```watchlog.timer``` будет каждые 30 секунд запускать сервис  ```watchlog.service```, если ключевое слово, заданное в ```/etc/sysconfig/keys``` найдено, в системных сообщениях ```/var/log/messages``` можно будет увидеть следующее:

```
Nov 20 19:26:41 wvds134871 systemd[1]: Starting My watchlog service...
Nov 20 19:26:41 wvds134871 root[5835]: Sat Nov 20 19:26:41 UTC 2021: I found word, Master!
Nov 20 19:26:41 wvds134871 systemd[1]: watchlog.service: Succeeded.
Nov 20 19:26:41 wvds134871 systemd[1]: Started My watchlog service.
Nov 20 19:26:41 wvds134871 systemd[1]: watchlog.service: Consumed 9ms CPU time
```

>если слово не найдено, мы увидим:

```
Nov 20 19:32:18 wvds134871 systemd[1]: Starting My watchlog service...
Nov 20 19:32:18 wvds134871 systemd[1]: watchlog.service: Succeeded.
Nov 20 19:32:18 wvds134871 systemd[1]: Started My watchlog service.
Nov 20 19:32:18 wvds134871 systemd[1]: watchlog.service: Consumed 4ms CPU time
```

По итогу:
* /etc/sysconfig/keys - наши переменные
* /var/log/test.log - лог файл
* /opt/myscript.sh - скрипт
* /etc/systemd/system/watchlog.service - сервис
* /etc/systemd/system/watchlog.timer - таймер запуска сервиса
---

### 2. Из репозитория epel установить spawn-fcgi и переписать init-скрипт на unit-файл (имя service должно называться так же: spawn-fcgi).

- Установим необходимое ПО:
```
yum install epel-release -y && yum install spawn-fcgi php php-cli mod_fcgid httpd -y
```
раскоментировать 2 последние строки в файле 
```/etc/sysconfig/spawn-fcgi```  

```
# You must set some working options before the "spawn-fcgi" service will work.
# If SOCKET points to a file, then this file is cleaned up by the init script.
#
# See spawn-fcgi(1) for all possible options.
#
# Example :
SOCKET=/var/run/php-fcgi.sock
OPTIONS="-u apache -g apache -s $SOCKET -S -M 0600 -C 32 -F 1 -P /var/run/spawn-fcgi.pid -- /usr/bin/php-cgi"
```

- Создадим файл сервиса
``` vim /etc/systemd/system/spawn-fcgi.service ``` :

```
[Unit]
Description=spawn-fcgi
After=network.target

[Service]
Type=simple
PIDFile=/var/run/spawn-fcgi.pid
EnvironmentFile=/etc/sysconfig/spawn-fcgi
ExecStart=/usr/bin/spawn-fcgi -n $OPTIONS
KillMode=process

[Install]
WantedBy=multi-user.target
```

- Стартуем
```
systemctl start spawn-fcgi
systemctl status spawn-fcgi
```

```
● spawn-fcgi.service - Spawn-fcgi startup service by Otus
   Loaded: loaded (/etc/systemd/system/spawn-fcgi.service; disabled; vendor preset: disabled)
   Active: active (running) since Sat 2021-11-20 20:55:21 UTC; 3s ago
 Main PID: 14970 (php-cgi)
    Tasks: 33 (limit: 4744)
   Memory: 18.8M
   CGroup: /system.slice/spawn-fcgi.service
           ├─14970 /usr/bin/php-cgi
           ├─14971 /usr/bin/php-cgi
           ├─14972 /usr/bin/php-cgi
           ├─14973 /usr/bin/php-cgi
           ├─14974 /usr/bin/php-cgi
           ├─14975 /usr/bin/php-cgi
           ...
```
---
### 3. Дополнить unit-файл httpd (он же apache) возможностью запустить несколько инстансов сервера с разными конфигурационными файлами. 

Юнит файл ``` /etc/systemd/system/httpd@.service ```:

```
[Unit]
Description=The Apache HTTP Server
After=network.target remote-fs.target nss-lookup.target
Documentation=man:httpd(8)
Documentation=man:apachectl(8)

[Service]
Type=notify
EnvironmentFile=/etc/sysconfig/%I
ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
ExecStop=/bin/kill -WINCH ${MAINPID}
KillSignal=SIGCONT
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```

---
полезные команды:
```systemd-cgtop``` - системный монитор ресурсов, systemd-юнитов.
> ```vi /etc/systemd/system.conf``` - config file system-monitor __systemd-cgtop__.  
> ```systemctl daemon-reexec``` - что бы перезагрузить файл конфигурации __systemd__ (файл - system.conf)

