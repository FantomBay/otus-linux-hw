#!/bin/bash
#======> Block variables <======
file_sy="ext4"  #failSystem
raid_level=6
disks_count=5
#===============================
part_step=$((100/$disks_count))#partitioning step
# Resetting the superblocks
mdadm --zero-superblock --force /dev/sd{b..f}
# Creating a RAID array
mdadm --create --verbose /dev/md0 --level $raid_level --raid-devices $disks_count /dev/sd{b..f}
# Creating a RAID configuration file - /etc/mdadm/mdadm.conf
mkdir /etc/mdadm
touch /etc/mdadm/mdadm.conf
echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
mdadm --detail --scan --verbose | awk '/ARRAY/{print}'>>/etc/mdadm/mdadm.conf
# Create GPT
parted --script /dev/md0 mklabel gpt
# Creating partitions
for i in $(seq 0 $part_step 100); do sudo parted /dev/md0 mkpart primary $file_sy $i% `expr $i + 20`%; done
#parted /dev/md0 mkpart primary $file_sy 20% 40%
#parted /dev/md0 mkpart primary $file_sy 0% 20%
#parted /dev/md0 mkpart primary $file_sy 40% 60%
#parted /dev/md0 mkpart primary $file_sy 60% 80%
#parted /dev/md0 mkpart primary $file_sy 80% 100%
# Creating file systems, Creating directories for partitions and Mount partitions
for i in $(seq 1 $disks_count)
do
    mkfs.$file_sy /dev/md0p$i
    mkdir -p /raid/part$i
    echo "/dev/md0p$i /raid/part$i    $file_sy    defaults        0 0" >> /etc/fstab
    #mount | grep data | awk '{print $1,$3,$5}'
done
mount -a