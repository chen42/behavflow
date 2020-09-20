#!/bin/bash

# experiment specific data files, daily ###

## get rats had surgery within 30 days but have no brevital results
echo "select a.RatID from Exp_JugularLineTests as a join Exp_JugularSurgery as b on a.RatID==b.RatID where IncludeRat is null and CAST ( julianday ( 'now' ) - julianday ( b.date ) AS integer ) < 30;" >surgeryrats.sql
surgeryFile="/home/hao/Dropbox/Pies/surgeryratIDs"
echo "RatID" >  $surgeryFile
sqlite3 /home/hao/Dropbox/ChenLab/p50phase2/HSRats2.sqlite <surgeryrats.sql >> $surgeryFile  
sqlite3 /home/hao/Dropbox/ChenLab/menthol_u01/menthol_u01.sqlite <surgeryrats.sql >> $surgeryFile


/home/hao/Dropbox/git/utility/medpc /home/hao/Dropbox/medpc/rawdata nosoffice
cd /home/hao/Dropbox/ChenLab/nightlyAnalyst
grep -a `date +"%m/%d/%y" -d "-1 day"` ../../medpc/rawdata.csv >today.csv 
grep -a `date +"%m/%d/%y" -d "-2 day"` ../../medpc/rawdata.csv >>today.csv 
grep -ai u01m today.csv >today_menthol.csv
grep -ai u01a today.csv >>today_menthol.csv
grep -ai p50B today.csv  > today_p50.csv
grep -ai oxy today.csv|grep -v oxy_hs |grep -v oxy_wky > today_oxy.csv
grep -ai oxy_hs today.csv  > today_oxy_hs.csv
grep -ai oxy_wky today.csv  > today_oxy_wky.csv

# U01 database updates
perl /home/hao/Dropbox/git/utility/mentholu01_schedule.pl
# U01 IVSA data  
perl /home/hao/Dropbox/git/utility/nightlyAnalyst.pl today_menthol.csv u01m_nicsa.xlsx
# P50 database updates
perl /home/hao/Dropbox/git/utility/p50_schedule.pl
# P50 IVSA data 
perl /home/hao/Dropbox/git/utility/nightlyAnalyst.pl today_p50.csv  p50_batch17.xlsx  

## animal ids for the slash /note command
## HS rats from UTHSC
rm ratids
echo "select RatID from RatUTHSC ;" > id.sql 
sqlite3 /home/hao/Dropbox/ChenLab/p50phase2/HSRats2.sqlite <id.sql >> ratids
## HS rats from WakeForest 
echo "select RatID from RatBreeders ;" > id.sql 
sqlite3 /home/hao/Dropbox/ChenLab/p50phase2/HSRats2.sqlite <id.sql >> ratids

echo "SELECT RatID FROM RatUTHSC AS a JOIN Breeding AS b ON a . BreedingSerial = b . SerialNumber where CAST ( julianday ( 'now' ) - julianday ( DOB ) AS integer ) <300 ;" >id.sql 
sqlite3 /home/hao/Dropbox/ChenLab/menthol_u01/menthol_u01.sqlite <id.sql >>ratids
cat ratids |awk '{print substr($0, 1+length($0)-4) "\t" $0}' >/home/hao/Dropbox/medpc/animalids.tab

# insert data from slack /note to sqlite
python slack_to_sqlite.py

