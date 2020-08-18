#!/bin/bash
# masquerading "für alle" via vmbr9

natif=vmbr9 #interface where the clients reside

if [ "$(cat /sys/class/net/$natif/operstate)" == "up" ] ; then
  natnet=$(/sbin/ip -f inet a $natif | awk '/inet/ { print $2 }'|head -1)
  defaultif=$(/sbin/ip -f inet route | awk '/default/ { print $5 }'|head -1)
  defaultgw=$(/sbin/ip -f inet route | awk '/default/ { print $3 }'|head -1)
  defaultnetip=$(/sbin/ip -f inet addr show $defaultif | awk '/inet/ { print $2 }'|cut -d"/" -f1|head -1)
  echo "1" > /proc/sys/net/ipv4/ip_forward
  iptables -t nat -A POSTROUTING -o $defaultif -s $natnet -j SNAT --to $defaultnetip
  iptables -t nat -A POSTROUTING -o $defaultif -s $natnet -j MASQUERADE
 fi
