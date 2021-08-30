скачать rpm пакет из репозитория можно командой:
```
# yumdownloader nginx - скачивает rpm-пакет
# yumdownloader --source nginx - src.rpm пакет
```
# RPM - RedHat package manager  
Часто используемые _rpm_ -_ключи:_
```bash
rpm -q|--query pckg_name # Установлен ли пакет|и его версия?
rpm -i *.rpm # Установить *.rpm файл.
rpm -e pckg_name # Удалить пакет.
rpm -qi pckg_name # Метаинформация пакета.
rpm -ql pckg_name # Список файлов пакета.
rpm -q --scripts pckg_name # Список скриплетов.
rpm -qR pckg_name # Зависимости для пекета.
rpm -qf FILE # проверить из какого пакета, любой файл в системе.
rpm2cpio FILE.rpm | cpio -idmv # Распаковать файл.rmp
```
### RPM-верификация ( -V )

* rpm -Va # верефикация всех файлов из rpm в системе.
```bash
# После установки пакета:

rpm -Vv nginx
.........  c /etc/nginx/mime.types.default
.........  c /etc/nginx/nginx.conf
.........  c /etc/nginx/nginx.conf.default
# После изменений в файле nginx.conf:
.........  c /etc/nginx/mime.types.default
S.5....T.  c /etc/nginx/nginx.conf
.........  c /etc/nginx/nginx.conf.default
```  
поднялись флаги изменений, существуют следующие типы флагов:  
>5 — контрольная сумма MD5  
S — размер  
L — символическая ссылка  
T — дата изменения файла  
D — устройство  
U — пользователь  
G — группа  
M — режим (включая разрешения и тип файла)  
? — файл не удалось прочитать  
missing — файл утерян\удален

Так же можно увидеть типы файлов:
>с - конфигурация  
d - документация  
l - лицензия  
r - readme файл  
g - %ghost -ставиться на удаленных пакетах

<font color="red">
<b> Если на против бинарного файла появились какие то флаги (см. выше), стоит задуматься оригинальный ли это бинарь или вам его подменили?
</font>

База данных rpm хранится в директории: ``` /var/lib/rpm/ ```  .
#### *Для хранения используется БД - "Berkeley DB".

Пример из жизни:
```bash
rm -f /var/lib/rpm/__db* 
db_verify /var/lib/rpm/Packages 
rpm --rebuilddb 
yum clean all
```
# Сборка rpm из исходников:
## для примера соберем 'redis'

Требуются пакеты:
* rpmdevtools
* rpm-build
```bash
sudo yum install rpmdevtools rpm-build -y
```
создаем каталог *rpmbuild* :
```bash
rpmdev-setuptree
```
>каталог имеет следующую структуру:  
/root/rpmbuild  
|-- BUILD -  директория в которой происходит сборка  
|-- RPMS - директория с собранными пакетами  
|-- SOURCES -  директория с исходными файлами  
|-- SPECS -  директория с spec-файлами  
`-- SRPMS - директория с SRPM-пакетами
```bash
yumdownloader --source redis
```
>в результате получим файл: 
```redis-3.2.12-2.el7.src.rpm```
```bash
rpm -ihv redis-3.2.12-2.el7.src.rpm
```
> в результате получим:
```
[root@repo ~]# tree rpmbuild/
rpmbuild/   
    |-- BUILD  
    |-- RPMS  
    |-- SOURCES  
    |   |-- 0001-1st-man-pageis-for-redis-cli-redis-benchmark-redis-c.patch  
    |   |-- 0002-install-redis-check-rdb-as-a-symlink-instead-of-dupl.patch  
    |   |-- redis-3.2.12.tar.gz  
    |   |-- redis-limit-init  
    |   |-- redis-limit-systemd  
    |   |-- redis-sentinel.init  
    |   |-- redis-sentinel.service  
    |   |-- redis-shutdown  
    |   |-- redis.init  
    |   |-- redis.logrotate  
    |   `-- redis.service  
    |-- SPECS  
    |   `-- redis.spec  
    `-- SRPMS  
```
Установим зависимости для redis кроме самой redis:
```bash
yum-builddep redis -y
```
теперь можно собирать:  
>rpmbuild -bb rpmbuild/SPECS/redis.spec - сборка rpm  
rpmbuild -bs rpmbuild/SPECS/redis.spec - сборка srpm  
rpmbuild -ba rpmbuild/SPECS/redis.spec - сборка rpm+srpm