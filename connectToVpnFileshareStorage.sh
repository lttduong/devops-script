#!/bin/bash
sudo mkdir -p /opt/vpn-profiles
if [ ! -d "/etc/smbcredentials" ]; then
sudo mkdir /etc/smbcredentials
fi
if [ ! -f "/etc/smbcredentials/stagingstorageaks.cred" ]; then
    sudo bash -c 'echo "username=stagingstorageaks" >> /etc/smbcredentials/stagingstorageaks.cred'
    sudo bash -c 'echo "password=mThljLiWTERhsTGVavi1GIv6gxt5WcWOB3Y4iiqnli2o75VzECwD7UCiCbonlgzIOhdBkjNqeMufHz0oxMYYAw==" >> /etc/smbcredentials/stagingstorageaks.cred'
fi
sudo chmod 600 /etc/smbcredentials/stagingstorageaks.cred

sudo bash -c 'echo "//stagingstorageaks.file.core.windows.net/vpn-profiles /opt/vpn-profiles cifs nofail,credentials=/etc/smbcredentials/stagingstorageaks.cred,dir_mode=0777,file_mode=0777,serverino,nosharesock,actimeo=30" >> /etc/fstab'
sudo mount -t cifs //stagingstorageaks.file.core.windows.net/vpn-profiles /opt/vpn-profiles -o credentials=/etc/smbcredentials/stagingstorageaks.cred,dir_mode=0777,file_mode=0777,serverino,nosharesock,actimeo=30