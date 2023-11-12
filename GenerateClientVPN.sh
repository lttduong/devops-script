#!/bin/bash
# Declere some env vars to auto generate client vpn
export AUTO_INSTALL="y"
export MENU_OPTION="1"
export CLIENT=$1
export PASS="1"
# Loop to generate 5 client ovpn files
for i in {1..5}; do
    bash openvpn-install.sh
    export CLIENT=${CLIENT//[0-9]/}$i
done

