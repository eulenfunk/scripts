#!/bin/sh
# reboot the box if gateway is not reachable (this is a hotfix)

function confline # get first line from file $1 mathing $2, stripped of # and ; comment lines, stripped spaces and tabs down to spaces, remove trailing ;
{
 echo $(cat $1|grep -v '^$\|^\s*\#'|sed -e "s/[[:space:]]\+/ /g"|sed s/^\ //|sed s/\;//|grep -i "$2"|head -n 1)
}

upgrade_started='/tmp/autoupdate.lock'
#wanif=$(cat /etc/config/network|grep -A 20 wan|grep ifname|head -1|tr -d "'"|tr -s " "|cut -d " " -f 3)
wanif=$(uci show|grep "network.lan.ifname"|tr -d "'"|cut -d= -f2)
#gateway=$(confline /etc/config/network gateway|tr -d "'"|tr -s " "|cut -d " " -f 3 )
gateway=$(uci show|grep "network.wan.ipaddr"|tr -d "'"|cut -d= -f2)

[ -f $upgrade_started ] && exit

nogw=false
ping -c 10 -W 1 $gateway &>/dev/nul|| nogw=true
echo nogw equals "$nogw"
if [ "$nogw" == "true" ] ; then
  logger gwcheck "gw $gateway NOT pingable"
  if [ -f /tmp/gw ] ; then
    if [ -f /tmp/gwgone.3 ] ; then
      [ -f $upgrade_started ] && exit
      logger gwcheck "rebooting"
      sleep 10
      reboot
    elif [ -f /tmp/gwgone.2 ] ; then
      touch /tmp/gwgone.3
      logger gwcheck "restarting networking and firewall"
      ifconfig $wanif down
      sleep 2
      ifconfig $wanif up
      /etc/init.d/network restart
      sleep 2
      /etc/init.d/firewall restart
    elif [ -f /tmp/gwgone.1 ] ; then
      touch /tmp/gwgone.2
      logger gwcheck "ifconfig down and up"
      ifconfig $wanif down
      sleep 3
      ifconfig $wanif up
    else
      touch /tmp/gwgone.1
    fi
  fi
else
  touch /tmp/gw
  logger gwcheck "gw $gateway pingable OK"
  rm -f /tmp/gwgone.* 2>/dev/null
fi

