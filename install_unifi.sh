#!/usr/sbin/env sh
dpkg=$1
unifi_file=/tmp/unifi_sysvinit_all.deb

wget -O $unifi_file $dpkg || curl -o $unifi_file $dpkg || echo 'Error downloading'

sudo apt install $unifi_file
rm -rf $unifi_file
echo "Done installing UniFi"
