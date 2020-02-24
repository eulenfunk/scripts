#!/bin/bash
# mini dnsmasq dhcp for masquerading network

natif=vmbr9 #interface where the clients reside
rangestart=100
rangeend=199

if [ "$(cat /sys/class/net/$natif/carrier)" == "1" ] ; then
  natnet=$(/sbin/ip -f inet a s $natif | awk '/inet/ { print $2 }'|head -1)
  natip=$(/sbin/ip -f inet a s $natif | awk '/inet/ { print $2 }'|cut -d"/" -f1|head -1)
  natbase=$(/sbin/ip -f inet a s $natif | awk '/inet/ { print $2 }'|cut -d"." -f1-3|head -1)
  defaultif=$(/sbin/ip -f inet route | awk '/default/ { print $5 }'|head -1 )
  defaultgw=$(/sbin/ip -f inet route | awk '/default/ { print $3 }'|head -1)
  defaultnetip=$(/sbin/ip -f inet addr show $defaultif | awk '/inet/ { print $2 }'|cut -d"/" -f1|head -1)
 cat > dnsmasqmini.conf << EOL
interface=$natif
server=/*/8.8.4.4
server=/*/8.8.8.8
dhcp-range=$natbase.$rangestart,$natbase.$rangeend,255.255.255.0,144h
dhcp-option=3,$natip
dhcp-option=6,$natip
dhcp-authoritative
no-negcache
port=0
EOL
 fi

 kill $(ps ax |grep dnsmasqmini.conf|grep "\-C" |awk '{ print $1 }'|head -1) 2>/dev/nul
 dnsmasq -C dnsmasqmini.conf



