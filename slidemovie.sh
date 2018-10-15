#!/bin/bash

# Script for converting list of files using ffmpeg to slide-movies
#
# https://github.com/eulenfunk/scripts/slidemovie.sh
#
# movie to slide
# 1) aus den Videos stur alle x (7s) ein Bild entnehmen und als JPEG speichern
# 2) sofern mehr als 4 Bilder, die jpegs nach Datei-Größe sortieren und dann die 40% kleinsten JPEGs löschen (das sind dann hoffentlich die unschärfsten)
# 4) sofern mehr als 5 Bilder, in Aufnahme-zeitlicher Reihenfolge durch die Bilder durchlaufen und jeweils Paare jeweils das kleinere Löschen.
# 4) aus den Verbliebenen rund 30% der Bilder einen Film bauen "alle 2s ein neues Photo" (H265, 5fps)

extension="mp4"
ext2="webm"
options="-y"
png="jpg"
thumb="slide"
delpercent="30"       # 30% der kleinsten Bilder löschen
smalldelthrethold="5" # nur bei mindestens 5 Bildern kleine Löschen
pairdelthreshold="8"  # nur wenn mindestens 3 Paare vorhanden sind mit dem Löschen anfangen.

for source in "$@"
 do
  test=1
  source="$(realpath "$source")"
  echo source "$source"
  base="$(echo "$source" | cut -d "." -f1)"
  tempfile="$(echo -n /tmp/$(echo $basename "$base"|md5sum|cut -c1-32))"
  target="$base.$thumb.$extension"
  target2="$base.$thumb.$ext2"
  echo "Converting: $source -> $target  - tempfile:$tempfile"

  # Do the conversion
  echo ffmpeg -y -i "$source" -skip_frame nokey -vf fps=1/10 "$tempfile.$thumb.%04d.$png"  -hide_banner
  ffmpeg  -y -i "$source"  -vf fps=1/7 "$tempfile.$thumb.%04d.$png"  -hide_banner
  tmpnames=$tempfile.$thumb."*".$png
# remove n % of smallest files.
  jpegstotal=$(ls -l $tmpnames|grep -c .$png)
  delcount=$(echo "$jpegstotal * $delpercent / 100  - 1"|bc)
  jpegs=$(ls -l $tmpnames |sort|tr -s " "|cut -d" " -f9-)
  echo delcount:$delcount - jpegs:$jpegs
  if [ "$jpegstotal" -ge "$smalldelthreshold" ] #nur wenn wir viele haben.
   then
    i=0
    for deljpeg in $jpegs
     do
      if [ "$i" -ge "$delcount" ]
       then
        break
       fi
      delfile=$(echo $deljpeg|tr -s " "|cut -d" " -f9-)
      echo rm "$delfile"
      rm "$delfile"
      i=$(echo $i + 1|bc)
     done
    fi
# remove smaller of pair
  if [ "$jpegstotal" -ge "$pairdelthreshold" ] #nur wenn wir viele haben.
   then
    even=0
    jpegs=$(ls -l $tmpnames |tr -s " "|cut -d" " -f9-)
    i=0
    for deljpeg in $jpegs
    do
     if [ "$i" -ge "1" ]
      then
       currentfile=$(echo $deljpeg)
       currentsize=$(stat --printf="%s" $currentfile)
       echo even?:$even size:$currentsize file:$currentfile
       if [ "$even" -eq "1" ]
        then
         if [ "$currentsize" -ge "$previoussize" ]
          then
           echo rm $previousfile
           rm $previousfile
          else
           echo rm $currentfile
           rm $currentfile
          fi
         even=0
        else
         previousfile=$currentfile
         previoussize=$currentsize
         even=1
        fi
      fi
     i=$(echo $i + 1|bc)
    done
   fi
#renumber
   jpegs=$(ls -l $tmpnames |tr -s " "|cut -d" " -f9-)
  renumbercount=0
  for deljpeg in $jpegs
   do
    newfile=$tempfile.$thumb.ren.$(printf "%04d" $renumbercount).$png
    echo mv $deljpeg $newfile
    mv $deljpeg $newfile
    i=$(echo $renumbercount + 1|bc)
   done
#encode
  if [ "$renumbercount" -ge "2" ] # erst ab 2 Bilder
   then
    echo  ffmpeg -r 1/2 -i "$tempfile".$thumb.ren.%04d.$png -c:v libx265 -vf "fps=10,format=yuv420p" "$target"
    ffmpeg -y -r 1/2 -i "$tempfile".$thumb.ren.%04d.$png -c:v libx265 -vf "scale=1920:-2,fps=5,format=yuv420p" "$target"
   fi
  rm    "$tempfile".$thumb.ren.*.$png
  # Adjust the modification date
  touch $(date -r "$source" +%s) "$target"
  #  mv "$target" "$target2"
 done
