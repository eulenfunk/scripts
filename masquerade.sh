#!/bin/bash
# enable SNAT/Masq for dns-served network via default ipv4 route (hypervisor-helperscript)

function confline # get first line from file $1 mathing $2, stripped of # and ; comment lines, stripped spaces and tabs down to spaces, remove trailing ;
{
 echo $(cat $1|grep -v '^$\|^\s*\#'|sed -e "s/[[:space:]]\+/ /g"|sed s/^\ //|sed s/\;//|grep -i "$2"|head -n 1)
}

dnsmasqconf="/etc/dnsmasq.conf"
#
default_iface=$(awk '$2 == 00000000 { print $1 }' /proc/net/route)
default_ipv4=$(ip -4 addr show dev "$default_iface" | awk '$1 ~ /^inet/ { sub("/.*", "", $2); print $2 }')
dhcp4_iface=$(confline $dnsmasqconf interface|cut -d"=" -f2)
dhcp4_network=$(ip -4 addr show dev "$dhcp4_iface" | awk '$1 ~ /^inet/ { sub(" .*", "", $2); print $2 }'|sed "s/\.1\//\.0\//")

echo default_iface "$default_iface"
echo default_ipv4 "$default_ipv4"
echo dhcp4_iface "$dhcp4_iface"
echo dhcp4_network "$dhcp4_network"

# Enable forwarding ipv4
echo "1" > /proc/sys/net/ipv4/ip_forward
##
iptables -t nat -A POSTROUTING -o $default_iface -s "$dhcp4_network" -j SNAT --to $default_ipv4
iptables -t nat -A POSTROUTING -o $default_iface -s "$dhcp4_network" -j MASQUERADE
