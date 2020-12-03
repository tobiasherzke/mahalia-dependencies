#!/bin/bash -ex
sudo rm -rf /opt/multistrap/
sudo multistrap -f multistrap-base.conf
mhamakedeb mahalia-dependencies.csv $(cat version) all
sudo cp preseed.conf configure_packages *.deb /opt/multistrap/
sudo chroot /opt/multistrap/ /configure_packages
sudo chroot /opt/multistrap dpkg -i *.deb
sudo rm /opt/multistrap/*.deb /opt/multistrap/preseed.conf /opt/multistrap/configure_packages

IMAGE=$PWD/mahalia_$(cat version).img
BOOTSIZE=$(( $(sudo du -ms /opt/multistrap/boot/ | cut -f 1) * 3 + 50 ))
TOTALSIZE=$(( $(sudo du -ms /opt/multistrap/ | cut -f 1) - $(sudo du -ms /opt/multistrap/boot/ | cut -f 1) + $BOOTSIZE + 150))
# create blank sd card image
sudo dd if=/dev/zero of=$IMAGE bs=1M count=$TOTALSIZE

# Create partitions
sudo fdisk $IMAGE <<EOF
n
p
1
2048
+${BOOTSIZE}M
t
c
a
n
p
2


w
EOF

# Mount and format partitions
DEVICE=`sudo kpartx -a -v $IMAGE | sed -E 's/.*(loop[0-9]*)p.*/\1/g' | head -1`
sudo mkfs.vfat "/dev/mapper/$DEVICE"p1
sudo mkfs.ext4 "/dev/mapper/$DEVICE"p2
sudo mkdir -p /mahalia
sudo mount "/dev/mapper/$DEVICE"p2 /mahalia
sudo mkdir -p /mahalia/boot
sudo mount "/dev/mapper/$DEVICE"p1 /mahalia/boot

# Copy content and unmount 
sudo rsync -a /opt/multistrap/ /mahalia/ || true
sudo umount "/dev/mapper/$DEVICE"p1
sudo umount "/dev/mapper/$DEVICE"p2
sudo kpartx -d $IMAGE
gzip -9 $IMAGE
