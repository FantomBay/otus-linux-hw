#!/bin/bash
#I added this section
dnf install nfs-utils -y
mkdir -p /var/nfs/info
echo "/var/nfs/info/ *(ro)" > /etc/exports
mkdir /var/nfs/upload
chmod o+rw /var/nfs/upload
echo "/var/nfs/upload/ *(rw,sync,no_root_squash,no_subtree_check)" >> /etc/exports
exportfs -rav
systemctl start nfs-server.service

# disable selinux or permissive 

selinuxenabled && setenforce 0

cat >/etc/selinux/config<<__EOF
SELINUX=disabled
SELINUXTYPE=targeted
__EOF