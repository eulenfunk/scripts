#!/bin/bash
interfaces=""
vmbrs=$(ls /sys/class/net|grep vmbr)
interfaces="$interfaces $vmbrs"
if [ ! -z "$interfaces" ]; then
  for interf in $interfaces; do
    echo $interf
    ifstate=$(cat /sys/class/net/$interf/operstate)
    if [ $ifstate == down ] ; then
      echo $interf restarting, due to $ifstate
      ifdown $interf; sleep 1; ifup $interf
     fi
   done
 fi
 
