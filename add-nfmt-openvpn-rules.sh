#!/bin/sh
iptables -t nat -I POSTROUTING 1 -s 10.8.0.0/24 -o tun1 -j MASQUERADE
iptables -I INPUT 1 -i tun0 -j ACCEPT
iptables -I FORWARD 1 -i tun1 -o tun0 -j ACCEPT
iptables -I FORWARD 1 -i tun0 -o tun1 -j ACCEPT
iptables -I INPUT 1 -i tun1 -p udp --dport 443 -j ACCEPT

#####################################
##   Saving iptables rules
#####################################
iptables-save 