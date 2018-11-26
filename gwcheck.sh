#!/bin/sh
# notnagel-script: openwrt-router rebooten, wenn er den uplink nimmer findet
upgrade_started='/tmp/autoupdate.lock'
gateway=172.29.5.1

[ -f $upgrade_started ] && exit

nogw=false
ping -c 10 -W 1 $gateway &>/dev/nul|| nogw=true
echo nogw equals "$nogw"
if [ "$nogw" == "true" ] ; then
  if [ -f /tmp/gw ] ; then # nur wenn er den uplinke überhaupt einmal gefunden hat. 
    if [ -f /tmp/gwgone.3 ] ; then
      [ -f $upgrade_started ] && exit
      reboot
    elif [ -f /tmp/gwgone.2 ] ; then
      touch /tmp/gwgone.3
    elif [ -f /tmp/gwgone.1 ] ; then
      touch /tmp/gwgone.2
    else
      touch /tmp/gwgone.1
    fi
  fi
else
  touch /tmp/gw
  rm -f /tmp/gwgone.* 2>/dev/null
fi
