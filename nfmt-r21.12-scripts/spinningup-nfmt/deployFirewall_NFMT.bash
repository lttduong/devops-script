#!/usr/bin/bash

# This script is used to set the firewall on NFMT VM starting R20.7

#################################
#Get the variables on this bench
#################################
echo "firewall now"
echo ""
iptables-save
echo ""
echo "Setting firewall now"
####################################################
#Firewall setup after docker and containers are UP
####################################################
iptables -F INPUT
iptables -F DOCKER-USER
iptables -F DEVOPS-FILTERS

iptables -A INPUT -i lo -j ACCEPT
iptables -N DEVOPS-FILTERS

#move all INPUT and DOCKER-USER chain to DEVOPS-FILTERS
iptables -A INPUT -j DEVOPS-FILTERS
iptables -A DOCKER-USER -j DEVOPS-FILTERS

##############################
#Now construct DEVOPS-FILTERS
##############################
#Accept any established connections
iptables -I  DEVOPS-FILTERS -m state --state RELATED,ESTABLISHED -j ACCEPT

#Accept connections from local interfaces and docker interfaces
iptables -A DEVOPS-FILTERS -i lo -j ACCEPT
iptables -A DEVOPS-FILTERS -i docker0 -j ACCEPT
iptables -A DEVOPS-FILTERS -i docker_gwbridge -j ACCEPT

# Allow NSP to access NFMT
###NSPHOSTIP
###NSPOSIP

#allow all traffic from within subnet of deployed machine + Private network
iptables -A DEVOPS-FILTERS -i eth0 -s 131.228.66.13 -j ACCEPT
iptables -A DEVOPS-FILTERS -i eth0 -s 131.228.66.14 -j ACCEPT
iptables -A DEVOPS-FILTERS -i eth0 -s 147.75.101.175 -j ACCEPT
iptables -A DEVOPS-FILTERS -i eth0 -s 20.123.140.188 -j ACCEPT
iptables -A DEVOPS-FILTERS -i eth0 -s 103.199.7.220 -j ACCEPT
iptables -A DEVOPS-FILTERS -i eth0 -s 172.20.4.0/20 -j ACCEPT
iptables -A DEVOPS-FILTERS -i eth0 -s 20.232.172.211 -j ACCEPT

# Following ports to be allowed as per NFMT firewall doc
# Split into two lines since it cannot take more than 15 ports in a command line.
#iptables -A DEVOPS-FILTERS -i eth0  -p tcp -s 10.1.1.0/24 -m multiport --dports 137,1194,4999,5003,443,1830,80,8443,8544,8444,8543,4999 -j ACCEPT
#iptables -A DEVOPS-FILTERS -i eth0  -p tcp -s 10.1.1.0/24 -m multiport --dports 9213,8546,8547,8548,8549,9092 -j ACCEPT

#iptables -A DEVOPS-FILTERS -i eth0  -p udp -s 10.1.1.0/24 --dport 9226 -j ACCEPT

#Log and block all others
iptables -A DEVOPS-FILTERS -m limit --limit 2/min -j LOG --log-prefix "IPTables-DEVOPS-FILTERS-Dropped: " --log-level 4
iptables -A DEVOPS-FILTERS -j DROP

##########################
#Firewall setup ends
##########################
echo "Firewall is set to below"
echo ""
iptables-save

