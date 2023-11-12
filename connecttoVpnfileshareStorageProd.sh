#!/usr/bin/bash

sudo mkdir -p /opt/prod/vpn-profiles
if [ ! -d "/etc/smbcredentials" ]; then
sudo mkdir /etc/smbcredentials
fi
if [ ! -f "/etc/smbcredentials/nokiaopenupprodstorage.cred" ]; then
    sudo bash -c 'echo "username=nokiaopenupprodstorage" >> /etc/smbcredentials/nokiaopenupprodstorage.cred'
    sudo bash -c 'echo "password=dDpHLqtbyEZMvonD2WIfAyqSaj8XstVs8fQoIUqPN7oXPOBKfRiqz9laGhqt9GQamTO1sBbfcPew+AStj4GUfg==" >> /etc/smbcredentials/nokiaopenupprodstorage.cred'
fi
sudo chmod 600 /etc/smbcredentials/nokiaopenupprodstorage.cred

sudo bash -c 'echo "//nokiaopenupprodstorage.file.core.windows.net/vpn-profiles /opt/prod/vpn-profiles cifs nofail,credentials=/etc/smbcredentials/nokiaopenupprodstorage.cred,dir_mode=0777,file_mode=0777,serverino,nosharesock,actimeo=30" >> /etc/fstab'
sudo mount -t cifs //nokiaopenupprodstorage.file.core.windows.net/vpn-profiles /opt/prod/vpn-profiles -o credentials=/etc/smbcredentials/nokiaopenupprodstorage.cred,dir_mode=0777,file_mode=0777,serverino,nosharesock,actimeo=30