#!/bin/bash
#
# Designed for a fairly standard Debian/Ubuntu desktop system
# Version 0.01-aug20013 (test)
# 
# Requires ccze
# <sudo apt-get install ccze>
#
# Put this script in /etc/init.d and run the following command line
# to modify /etc/init.d/rc.local and execute the script like a 
# service at the next boot:
# <sudo echo service firewall start >> /etc/init.d/rc.local>
#
# To run this script use:
# <sudo service firewall start|stop|reload>
# 
# dharma
#
	set -e
	echo
	if [ "$(id -u)" != "0" ]; then
	    echo " [+] Error: This script must be run as root." 1>&2
	    echo
	    echo "  $ sudo service firewall start|stop|reload" 1>&2
	    echo
	    exit 1
	fi
	echo " [+] Setting up rules:"
	echo

ready(){
	iptables --policy INPUT DROP
	#iptables --policy FORWARD DROP
	iptables -A INPUT -i lo -j ACCEPT
	iptables -A INPUT -p tcp --syn -j DROP
	iptables -A INPUT -p icmp --icmp-type echo-request -j DROP
	echo 1 > /proc/sys/net/ipv4/conf/default/rp_filter
	iptables -A INPUT -m state --state INVALID -j DROP
	iptables -A INPUT -p tcp -m tcp --dport 101 --syn -j ACCEPT
	iptables --policy OUTPUT ACCEPT
	iptables --append INPUT --match state --state ESTABLISHED,RELATED --jump ACCEPT
	iptables --append INPUT --jump DROP
	#iptables --append FORWARD --jump DROP
	#iptables --policy OUTPUT DROP
	iptables --append OUTPUT --protocol udp --match multiport --dports domain,bootps --jump ACCEPT
	iptables --append OUTPUT --protocol tcp --match multiport --dports domain,http,https,ssh,pop3s,imaps,submission --jump ACCEPT
	echo " [+] Firewall rules up:"
        echo
	iptables -L | ccze -A
        echo
}

stop(){
	iptables -F
	iptables -P INPUT ACCEPT
	iptables -P OUTPUT ACCEPT
        echo
	echo " [+] Firewall rules down:"
        echo
}

	case "$1" in
	"start") ready ;;
	"stop") stop ;;
	"reload") stop; ready ;;
	*) echo " --> Use start|stop|reload options"
	esac
