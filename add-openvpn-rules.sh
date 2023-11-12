#!/bin/sh
iptables -t nat -I POSTROUTING 1 -s 10.8.0.0/24 -o eth0 -j MASQUERADE
iptables -I INPUT 1 -i tun0 -j ACCEPT
iptables -I FORWARD 1 -i eth0 -o tun0 -j ACCEPT
iptables -I FORWARD 1 -i tun0 -o eth0 -j ACCEPT
iptables -I INPUT 1 -i eth0 -p udp --dport 1194 -j ACCEPT
