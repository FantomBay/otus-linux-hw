yum install xfsdump
pvcreate /dev/sdb
vgcreate vg_root /dev/sdb
lvcreate -n lv_root -l +100%FREE /dev/vg_root
mkfs.xfs /dev/vg_root/lv_root
mount /dev/vg_root/lv_root /mnt
 
xfsdump -J - /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt
for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
chroot /mnt/
И в chroot:
grub2-mkconfig -o /boot/grub2/grub.cfg # хотя в презентации указано что эта комманда выполняется не из chroot а из "~" директории
#[root@lvm /]# grub2-mkconfig -o /boot/grub2/grub.cfg
#Generating grub configuration file ...
#Found linux image: /boot/vmlinuz-3.10.0-862.2.3.el7.x86_64
#Found initrd image: /boot/initramfs-3.10.0-862.2.3.el7.x86_64.img
#done
а если это выполнять из "~" (не из чрута):
#[root@lvm ~]# grub2-mkconfig -o /boot/grub2/grub.cfg
#Generating grub configuration file ...
#Found linux image: /boot/vmlinuz-3.10.0-862.2.3.el7.x86_64
#Found initrd image: /boot/initramfs-3.10.0-862.2.3.el7.x86_64.img
#Found CentOS Linux release 7.5.1804 (Core)  on /dev/mapper/vg_root-lv_root
#done
Тогда следует указать что при перезагрузке нужно выбрать в меню загрузки нужный пункт (см.скрин)

lvremove /dev/VolGroup00/LogVol00
lvcreate -n VolGroup00/LogVol00 -L 8G /dev/VolGroup00
mkfs.xfs /dev/VolGroup00/LogVol00
mount /dev/VolGroup00/LogVol00 /mnt
xfsdump -J - /dev/vg_root/lv_root | xfsrestore -J - /mnt

for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done

chroot /mnt/
grub2-mkconfig -o /boot/grub2/grub.cfg
cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g; s/.img//g"` --force; done

pvcreate /dev/sdc /dev/sdd
vgcreate vg_var /dev/sdc /dev/sdd
lvcreate -L 950M -m1 -n lv_var vg_var
mkfs.ext4 /dev/vg_var/lv_var
mount /dev/vg_var/lv_var /mnt
cp -aR /var/* /mnt/   
#Следующая комманда в презентации соит в одну строку с предыдущей (возможно опечатка)
rsync -avHPSAX /var/ /mnt/
mkdir /tmp/oldvar && mv /var/* /tmp/oldvar
umount /mnt
mount /dev/vg_var/lv_var /var
echo "`blkid | grep var: | awk '{print $2}'` /var ext4 defaults 0 0" >> /etc/fstab
script
#По итогу команда script - создает пустой файл typescript
touch /home/file{1..20}
lvcreate -L 100MB -s -n home_snap /dev/VolGroup00/LogVol_Home
rm -f /home/file{11..20}
umount /home
lvconvert --merge /dev/VolGroup00/home_snap
mount /home

