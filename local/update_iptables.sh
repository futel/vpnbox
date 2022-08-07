#!/usr/bin/env bash
# Set up iptables rules, must be saved afterwards.
# These are the rules that require the tunnel interface to exist first.

# allow established and forward on the vpn tunnel
iptables -A FORWARD -i eth0 -o tun0 -m state --state RELATED,ESTABLISHED -j ACCEPT 
#iptables -A FORWARD -i eth0 -o tun1 -m state --state RELATED,ESTABLISHED -j ACCEPT 
iptables -A FORWARD -i tun0 -o eth0 -j ACCEPT
#iptables -A FORWARD -i tun1 -o eth0 -j ACCEPT

# let dns in and out on the vpn tunnel
iptables -A INPUT -i tun0 -p udp --dport 53 -j ACCEPT
#iptables -A INPUT -i tun1 -p udp --dport 53 -j ACCEPT
iptables -A INPUT -i tun0 -p tcp --dport 53 -j ACCEPT
iptables -A INPUT -i tun1 -p tcp --dport 53 -j ACCEPT
