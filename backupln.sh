#!/bin/bash

backupuser="pmback-$(hostname)"
dumpdir=/var/lib/vz/dump/
ddirlen=${#dumpdir}
cut1=$(expr $ddirlen + 1)
cut2=$(expr $ddirlen + 15)
if [ ! -d "/home/$backupuser" ]; then
  echo "/home/$backupuser does not exist, exiting $0"
  exit
 fi
if [ ! -d "/home/$backupuser/pmbackup" ]; then
  mkdir /home/$backupuser/pmbackup
 fi
if [ ! -d "/home/$backupuser/pmbackup" ]; then
  echo "/home/$backupuser/pmbackup not creatable, exiting $0"
  exit
 fi
chown $backupuser:$backupuser /home/$backupuser/pmbackup

rm /home/$backupuser/pmbackup/* 2>/dev/nul
backupvms=$(find $dumpdir -maxdepth 1 -a -type f -a -name '*.gz' -o -name '*.lzo' |cut -c $cut1-$cut2|sort|uniq)
echo backupvms: $backupvms

for backupvm in $backupvms; do
  backupfile=$(find /var/lib/vz/dump/ -maxdepth 1 -a -name "$backupvm*" -a  \( -name "*.lzo" -o -name "*.gz" \) -printf '%T+ %p\n' |sort -r|cut -d" " -f2|head -1)
  backupfilename=$(basename -- "$backupfile")
  ln -s $backupfile /home/$backupuser/pmbackup/$backupfilename
 done
