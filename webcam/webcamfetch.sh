#!/bin/bash
#
# live: http://cam.ffgek.de/signalcam.html
#
# script relies on 
#  - Imagemagick
#  - FredWeinhaus Tools 
#     http://www.fmwconcepts.com/imagemagick/
#     https://github.com/chexov/fmwconcepts-imagemagicktools/blob/master/bin/autocolor


# this is a hack
export LC_ALL=de_DE.utf8

# $1=save -> backup this file to the savedir.

# URL of jpg-snapshot
camadr="http://10.28.0.30:81/snapshot.cgi?"
# subtile for the big picture
subtitlelang="Heinrich-König-Platz   via   www.freifunk-gelsenkirchen.de"
# tool paths
wget=/usr/bin/wget
convert=/usr/bin/convert
composite=/usr/bin/composite
autocolor=/opt/webcam/autocolor
fontdir=/usr/share/fonts/TTF

scriptdir=/opt/webcam
webdir=/srv/http/cam

# file containing webcam-login-info
login=$(cat camlogin.conf)

# nicer filenames would be nice...
getfile=signalcam.jpg
putfile4=signalcam4.jpg
putfile3=signalcam3.jpg
putfile=signalcam2.jpg
putfilesmall=signalcam2small.jpg
savedir=arch


# date stamps for big and thumb
datumkurz=$(date +"%a %d %b %y %T")
datumlang=$(date +"%a %d %b %Y %H:%M:%S")


# encode to ISO8859-1 for imagemagick
datumlang=$(echo $datumlang|recode utf-8..ISO-8859-1)
datumkurz=$(echo $datumkurz|recode utf-8..ISO-8859-1)
subtitlelang=$(echo $subtitlelang|recode utf-8..ISO-8859-1)
minsize=20000
# dont archive files smaller than archminsize (probably broken jpg)
archminsize=190000
archfile=signalcam-$(date +"%s %c").jpg
cd $webdir
$wget "$camadr$login" -O $webdir/$getfile

filesizesize=$(wc -c <"$getfile")
if [ $filesizesize -ge $minsize ]; then
  $convert $getfile /dev/null
  if [ $? -eq 0 ]; then
    $autocolor -c together $getfile $putfile4
    $convert $putfile4 \
     -magnify \
     -quality 92 \
     -fill '#0008' -draw 'rectangle 738,30,1266,84' \
     -fill '#0008' -draw 'rectangle 974,88,1266,300' \
     -gravity NorthWest -font $fontdir/arial.ttf -pointsize 44  -fill white -annotate +750+30 "$datumlang" \
     -gravity South -font $fontdir/times.ttf -pointsize 44 -background black -splice 0x52 -annotate +0+4 "$subtitlelang" \
     $putfile3
    $composite -quality 92 -geometry +980+88 $scriptdir/ffdouble.png $putfile3 $putfile
    $convert -quality 92 -resize 270 -quality 85 $getfile \
     -gravity South -font $fontdir/arial.ttf -pointsize 15 -background black -fill white -splice 0x18 -annotate +0+0 "$datumkurz" \
     $putfilesmall
    archfilesize=$(wc -c <"$putfile")
    if [ "$1" = "save" ]; then
      if [ $archfilesize -ge $archminsize ]; then
        cp $putfile "$savedir/$archfile"
       fi
     fi
   fi
fi
