sudo -i
yum install xfsdump
pvcreate /dev/sdb
vgcreate vg_root /dev/sdb
lvcreate -n lv_root -l +100%FREE /dev/vg_root
mkfs.xfs /dev/vg_root/lv_root
mount /dev/vg_root/lv_root /mnt
xfsdump -J - /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt
ls /mnt
for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
chroot /mnt/
    grub2-mkconfig -o /boot/grub2/grub.cfg
    cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g; s/.img//g"` --force; done
    vi /boot/grub2/grub.cfg
    exit
reboot


sudo -i
lvremove /dev/VolGroup00/LogVol00
lvcreate -n VolGroup00/LogVol00 -L 8G /dev/VolGroup00
mkfs.xfs /dev/VolGroup00/LogVol00
mount /dev/VolGroup00/LogVol00 /mnt
xfsdump -J - /dev/vg_root/lv_root | xfsrestore -J - /mnt
for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
chroot /mnt/
    lsblk
    grub2-mkconfig -o /boot/grub2/grub.cfg
    cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g; s/.img//g"` --force; done
    pvcreate /dev/sdc /dev/sdd
    vgcreate vg_var /dev/sdc /dev/sdd
    lvcreate -L 950M -m1 -n lv_var vg_var
    mkfs.ext4 /dev/vg_var/lv_var
    mount /dev/vg_var/lv_var /mnt
    cp -aR /var/* /mnt/
    rsync -avHPSAX /var/ /mnt/
    mkdir /tmp/oldvar && mv /var/* /tmp/oldvar
    umount /mnt
    mount /dev/vg_var/lv_var /var
    echo "`blkid | grep var: | awk '{print $2}'` /var ext4 defaults 0 0" >> /etc/fstab
    exit
reboot



sudo -i
#Удаление ненужного раздела
lvremove /dev/vg_root/lv_root
vgremove /dev/vg_root
pvremove /dev/sdb
########Создание SNAPSHOT и востановление с него
lvcreate -n LogVol_Home -L 2G /dev/VolGroup00
mkfs.xfs /dev/VolGroup00/LogVol_Home
mount /dev/VolGroup00/LogVol_Home /mnt/
cp -aR /home/* /mnt/
rm -rf /home/*
umount /mnt
mount /dev/VolGroup00/LogVol_Home /home/
echo "`blkid | grep Home | awk '{print $2}'` /home xfs defaults 0 0" >> /etc/fstab
touch /home/file{1..20}
lvcreate -L 100MB -s -n home_snap /dev/VolGroup00/LogVol_Home
rm -f /home/file{7..17}
umount /home
lvconvert --merge /dev/VolGroup00/home_snap
mount /home



