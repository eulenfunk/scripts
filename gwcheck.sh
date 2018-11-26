#!/bin/sh
upgrade_started='/tmp/autoupdate.lock'
gateway=...
wanif=eth0.2

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
      ifconfig wanif down
      sleep 2
      ifconfig wanif up
      /etc/init.d/networking restart
      sleep 2
      /etc/init.d/firewall restart
    elif [ -f /tmp/gwgone.1 ] ; then
      touch /tmp/gwgone.2
      logger gwcheck "ifconfig down and up"
      ifconfig wanif down
      sleep 3
      ifconfig wanif up
    else
      touch /tmp/gwgone.1
    fi
  fi
else
  touch /tmp/gw
  logger gwcheck "gw $gateway pingable OK"
  rm -f /tmp/gwgone.* 2>/dev/null
fi
