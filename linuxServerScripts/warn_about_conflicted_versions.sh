#!/bin/bash

# setup for directories to monitor
d1=""
d2=""
d3=""
d4=""


old="/tmp/conflictold"
new="/tmp/conflictnew"


for i in $d1 $d2 $d3 $d4 ; do 
	ls $i >>$old
done


while true; do 
	sleep 1

	for i in $d1 $d2 $d3 $d4 ; do 
		ls $i >>$new
	done
	change=`diff $new $old |grep conflicted | grep "<"  |sed "s/< /*/"`
	if [ ${#change} -gt 1 ] ; then 
		msg="Who created a conflicted version of "$change"* in dropbox??"
		echo $msg 
		# curl -X POST -H 'Content-type: application/json' --data '{"text": "'"$msg"'",  "username": "Attention!", "icon_emoji": ":hurtrealbad:"}' https://
		# add your url above.
	fi
	mv $new $old
done


