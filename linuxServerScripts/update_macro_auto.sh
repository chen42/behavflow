#!/bin/bash


# ns016.schedule.xlsx is the spreadsheet that sets up rat's schedule
LAST=`md5sum /home/hao/Dropbox/medpc/ns016.schedule.xlsx`
while true; do
  sleep 1
  NEW=`md5sum /home/hao/Dropbox/medpc/ns016.schedule.xlsx`
  if [ "$NEW" != "$LAST" ]; then
    LAST="$NEW"
    cd /home/hao/ 
	dailymac ## this is the script that converts spreadsheet to medpc macro 
	chown -R hao /home/hao/Dropbox/medpc/   
  fi

done
