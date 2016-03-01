#!/bin/bash
camadr="http://10.28.0.30:81/snapshot.cgi?"
login=$(cat camlogin.conf)
export LC_ALL=de_DE.utf8
getfile=signalcam.jpg
putfile4=signalcam4.jpg
putfile3=signalcam3.jpg
putfile=signalcam2.jpg
putfilesmall=signalcam2small.jpg
datumkurz=$(date +"%a %d %b %y %T")
datumlang=$(date +"%a %d %b %Y %H:%M:%S")
subtitlelang="Heinrich-König-Platz  via  www.freifunk-gelsenkirchen.de"
datumlang=$(echo $datumlang|recode utf-8..ISO-8859-1)
datumkurz=$(echo $datumkurz|recode utf-8..ISO-8859-1)
subtitlelang=$(echo $subtitlelang|recode utf-8..ISO-8859-1)
minsize=20000
archminsize=190000
archfile=signalcam-$(date +"%s %c").jpg
cd /srv/http/cam
/usr/bin/wget "$camadr$login" -O /srv/http/cam/signalcam.jpg

filesizesize=$(wc -c <"$getfile")
if [ $filesizesize -ge $minsize ]; then
  convert $getfile /dev/null
  if [ $? -eq 0 ]; then
    /opt/webcam/autocolor -c together $getfile $putfile4
    /usr/bin/convert $putfile4 \
     -magnify \
     -quality 92 \
     -fill '#0008' -draw 'rectangle 738,30,1266,84' \
     -fill '#0008' -draw 'rectangle 974,88,1266,300' \
     -gravity NorthWest -font Arial -pointsize 44  -fill white -annotate +750+30 "$datumlang" \
     -gravity South -font Times -pointsize 44 -background black -splice 0x52 -annotate +0+4 "$subtitlelang" \
     $putfile3
    /usr/bin/composite -quality 92 -geometry +980+88 ffdouble.png $putfile3 $putfile
    /usr/bin/convert -quality 92 -resize 270 -quality 85 $getfile \
     -gravity South -font Arial -pointsize 15 -background black -fill white -splice 0x18 -annotate +0+0 "$datumkurz" \
     $putfilesmall
    archfilesize=$(wc -c <"$putfile")
    if [ $1 = "save" ]; then
      if [ $archfilesize -ge $archminsize ]; then
#        echo saving $putfile to backup $archfile
        cp $putfile "arch/$archfile"
       fi
     fi
   fi
fi
