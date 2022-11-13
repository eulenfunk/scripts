#!/bin/sh
# reboot the box if workdping or other hosts are reachable
# this is a hotfix against 'locked in syndrome' boxes

addhosts="8.8.8.8 8.8.4.4 1.1.1.1 9.9.9.9"
wait=1
count=3
gwlostcount=/tmp/gwlostcount
gwseen=/tmp/gw

upgrade_started='/tmp/autoupdate.lock'
wanif=$(uci -q show network.wan.device|cut -d"=" -f2|tr -d \')
#gwv4=$(ip -4 r s|grep ^default|head -1|awk '{print $3}')
#gwv6=$(ip -6 r s|grep ^default|head -1|awk '{print $3}')
gwv4=$(mtr -4 -n -m 1 8.8.8.8 -l -c1 -G1|grep "^h "|awk '{print $3}')
#gwv6=$(mtr -6 -n -m 1 www.heise.de -l -c1 -G1|grep "^h "|awk '{print $3}')
checkhosts=$(echo $gwv4 $addhosts)
#checkhosts=$(echo $addhosts)

# do not check while fw upgrade
[ -f $upgrade_started ] && exit

# did we see the gw before?
onisland=1
[ -f $gwseen ] && onisland=0

# checkfor host
ipfail=true
for host in $checkhosts ; do
  # abort check if at least one host is pingable
#  echo ping -c $count -W $wait $host
  ping -c $count -W $wait $host &>/dev/nul && ipfail=false && break
 done
# register nogw-counter in semaphore-file
if [ "$ipfail" == "false" ] ; then
  [ -f $gwlostcount.* ] && logger -s worldping "OK on $host out of $checkhosts, deleting gwlostcount" && rm -f $gwlostcount.* 2>/dev/null
  [ $onisland -eq 1 ] && echo 1>$gwseen # we are not on an island
 else
  if [ ! -f $gwlostcount.* ] ; then
    oldnum=0
   else
    oldnum=$(cat $gwlostcount.*)
    rm -f $gwlostcount.* 2>/dev/null
   fi
  newnum=$(expr $oldnum + 1)
  echo $newnum>$gwlostcount.$newnum
  logger -s worldping "none of $chechosts longer pingable, lostcount=$newnum"
  if [ $onisland -eq 0 ] ; then  # dont start action if we have never seen the world since reboot
    if [ $newnum -eq 4 ] ; then
      [ -f $upgrade_started ] && exit
      logger -s worldping "rebooting"
      sleep 10
      reboot
    elif [ $newnum -eq 3 ] ; then
      logger -s worldping "restarting networking and firewall"
      ifconfig $wanif down
      sleep 2
      ifconfig $wanif up
      sleep 2
      /etc/init.d/network restart
      sleep 2
      /etc/init.d/firewall restart
    elif [ $newnum -eq 2 ] ; then
      logger -s worldping "network restart"
      /etc/init.d/network restart
     fi
   fi
 fi
