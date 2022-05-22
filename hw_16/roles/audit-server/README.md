Role Name
=========

audit-server

Requirements
------------

Данная роль указывает переменную tcp_listen_port в файле /etc/audit/auditd.conf.
Перезагружает сервис auditd

Role Variables
--------------

Укажите порт, на котором будет слушать auditd (по умолчанию 60)
remote_port: х

Author Information
------------------

FantomBay

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
