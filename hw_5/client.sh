#!/bin/bash
#I added this section

mkdir /mnt/nfs_upload
mkdir /mnt/nfs_info
echo "10.0.0.41:/var/nfs/upload /mnt/nfs_upload nfs defaults 0 0" >> /etc/fstab
echo "10.0.0.41:/var/nfs/info /mnt/nfs_info nfs defaults 0 0" >> /etc/fstab
mount -a

# disable selinux or permissive 

selinuxenabled && setenforce 0

cat >/etc/selinux/config<<__EOF
SELINUX=disabled
SELINUXTYPE=targeted
__EOF
