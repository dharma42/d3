#!/bin/bash
# Should be called wireless2wire.sh
# Internet between friends! 
# Script to share Internet from wireless connection to wired.
# Designed for a fairly standard Debian/Ubuntu desktop system.
#
# Requires dnsmasq:
# sudo apt-get install dnsmasq
# 
# Requires ccze:
# sudo apt-get install ccze
#
# Make owner root:
# sudo chown root:root wireless2wire.sh
# 
# Make executable:
# sudo chmod u+x wireless2wire.sh
#
# Copy to executable path:
# sudo cp wireless2wire.sh /usr/local/bin
#
# Run as root:
# sudo wireless2wire.sh
#
# Edit next line if your router is on the same subnet,
# e.g. 192.168.10.X
#

        set -e
	if [ "$(id -u)" != "0" ]; then
	    echo "Error: This script must be run as root." 1>&2
	    echo
	    echo "  $ sudo wireless2wired start|stop|reload|help" 1>&2
	    echo
	    exit 1
        if

clean(){
        cat /dev/null > /etc/dnsmasq.conf
        service firewall reload
        #remove route 192.168.10    
}

wireless2wired(){
        ifconfig eth0 "$SUBNET".1 netmask 255.255.255.0
	sysctl -w net.ipv4.ip_forward=1
	echo "interface=eth0" > /etc/dnsmasq.conf
	echo "dhcp-range="$SUBNET".10,"$SUBNET".100,4h" >> /etc/dnsmasq.conf
	iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
	iptables -F FORWARD
	iptables -A FORWARD -j ACCEPT
        echo
	service dnsmasq restart
        echo
        echo " [+] Firewall Status:"
	iptables -nvL
        echo
        echo " [+] DNSMasq config:"
        echo
	cat /etc/dnsmasq.conf | ccze -A
        echo
        echo " [+] Routes:"
        echo
	route -n
        echo
        echo " [+] Logs:" 
        echo
	tail -f /var/log/syslog | ccze -A 
}

ready(){
	    SUBNET=192.168.10
            sleep 0.3
            wirelles2wired
}

	case "$1" in
        "start") ready ; wireless2wired ;;
        "reaload") stop ; start ;; 
        "stop") clean ;;
        "*") echo " Please, run wireless2wired start|stop|restart"
        esac



# Now your friend should be able to check, see the syslog,get an IP 
# through a cable between your computer and hers, and use your 
# wireless connection.
#
# When you finish the conection, reboot your computer. 
#
# Dharma
# Fuente: http://chrisjrob.com/2011/03/14/sharing-a-wireless-connection-via-ethernet-port/
