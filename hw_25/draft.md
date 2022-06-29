server:

yum install ipa-server

yum install ipa-server-dns

timedatectl set-timezone Europe/Moscow

systemctl enable chronyd --now

setenforce 0

sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config

hostnamectl set-hostname freeipa.otus.local

sed -i -e '$ a192.168.10.10 freeipa.otus.local' /etc/hosts

ipa-server-install --setup-dns
	Server host name [freeipa.otus.local]: enter
	Please confirm the domain name [otus.local]: enter
	Please provide a realm name [OTUS.LOCAL]: enter
	Directory Manager password: $pwgen (caighiM6Oseig4Oecaan)
	IPA admin password: $pwgen (jem7Obu0saizoong7iev)
	Do you want to configure DNS forwarders? [yes]: no
	Do you want to search for missing reverse zones? [yes]: no
	Continue to configure the system with these values? [no]: yes
	
	
	
	
	
	
===
Полумера для безопасности LDAP сервера:
Желательно использовать ssl-сертификаты для ldap что бы не проснифели пароли через http.
Если утечет досуп к LDAP - утекут все учетные записи

Этапы настройки sever:
	OpenLDAP Client
	SSSD
	PAM - для осуществления аутентификации через нее
	SSH - для работы с ssh
	NSS - 
	oddjob - для создания домашних директорий пользователей


