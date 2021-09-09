#!/bin/bash

F="/home/hao/Dropbox/ChenLab/macro_scripts/save_this_file_to_update_schedule.txt"
new="/home/hao/Dropbox/medpc/.schedule_new"
old="/home/hao/Dropbox/medpc/.schedule_old"
eventtime=`date +%s`

while true; do
	mv $new $old
	message=''
	user=''
	ls -lt $D |grep -v "TEST" | sed "s/_noWght_/noWght_/" |sed "s/ \+/\t/g"|cut -f 5,6,7,8,9 > $new
	room=`diff $new $old |grep "<" |cut -f 5 |cut -f 1 -d "_" |sort |uniq ` 
	grp=`diff $new $old |grep "<"  |cut -f 5 |cut -f 5 -d "_" |sed "s/.Group//"|sort |uniq |tr '\n' ' ' ` 
	animal=`diff $new $old |grep "<" |cut -f 5 |cut -f 3 -d "_" |sort |uniq |tr '\n' ' ' `
	animalnum=`diff $new $old |grep "<" |cut -f 5 |cut -f 3 -d "_" |sort |uniq |wc -l`
#	echo "Room $room"
#	echo "Grp $grp"
#	echo "animal number  $animalnum"
#	echo "animal $animal"

# grammar
	if [[ $animalnum -eq 1 ]]
		then 
			is="is"
			it="it"
		else
			is="are"
			it="them"
	fi
	
# user
	user="@Angel @twang18 @hao" 

# message
	if [[ -n $user  && $animal ]]  
		then 
			now=`date +%s`
			lapsed=`expr $now - $eventtime`
			if [[ $lapsed -gt 600 ]] ## slightly different language if just sent a message 
				then 
					message="$user :rat:  $animal [ $grp ] $is finished. Time to take $it out. "
				else 
					message="$user :rat:  $animal $is also done. "
			fi
	fi

# incomplete assasys 

fr10=`diff $new $old |grep "<" |cut -f 5 |grep -i fr[0-9] | sed "s/noWght_/_noWght_/" |grep -v "_1h" ` 
	for i in $fr10
		do 
			i="/home/hao/Dropbox/medpc/rawdata/"$i

			echo "File: $i"	
			sec=$(grep "S:" "$i" |tail -n 1 |sed "s/ \+/\t/"|cut -f 2 |cut -f 1 -d ".")
			box=$(grep "Box:" "$i" |tail -n 1|sed "s/\r//")
			rat=$(echo "$i" | cut -f 3 -d "_")	
			#echo "box $box"
			if [[ $sec -lt 9000 ]]  
				then
					left=$((9000-sec))
					left_min=$((left/60+1))
					hour=$((sec/3600))
					tmp=$((sec%3600))
					min=$((tmp/60))
					message2="$message2 :scream: $user $rat (Computer $room $box) only ran *$hour h $min m*. Please restart it for $left_min minutes."
			fi
	done


# 0 lick counts 

newSession=`diff $new $old |grep "<" |cut -f 5 |grep -i fr[0-9] | sed "s/noWght_/_noWght_/" ` 

for i in $newSession
		do 
			i="/home/hao/Dropbox/medpc/rawdata/"$i
			#echo "new file: $i"
			rat=$(echo "$i" | cut -f 3 -d "_")	
			act=$(grep "A:" "$i" |tail -n 1 |sed "s/ \+/\t/"|cut -f 2 |cut -f 1 -d ".")
			ina=$(grep "B:" "$i" |tail -n 1 |sed "s/ \+/\t/"|cut -f 2 |cut -f 1 -d ".")
			box=$(grep "Box:" "$i" |tail -n 1|sed "s/\r//")
			id=${rat:(-4)}
			if [[ $act -eq 0 ]]  
				then
					message3="$message3 $user $rat (computer $room $box) had *0 active* licks. Please :heavy_check_mark: if the spout is working and leave a note in slack:\n/note rat $id active spout failure | OK ."
			fi

			if [[ $ina -eq 0 ]]  
				then
					message3="$message3 \n $user  $rat (computer $room $box) had *0 inactive* licks. Please :heavy_check_mark: if the spout is working and leave a note in slack:\n/note rat $id inactive spout failure | OK ."
			fi

			if [[ $act -gt 500 ]]  
				then
					message3="$message3 \n $user $rat (computer $room $box) had *$act active* licks. If this is a nicotine #rat, please check if the infusion system is leaking and leave a note in slack: \n/note rat $id infusion system leak | OK ."
			fi
done

# send the message
	url=''
	if [[ -n $message ]] 
		then 
			message="$message Thanks."
			echo "$message"
			curl -X POST -H 'Content-type: application/json' --data '{"text": "'"$message"'",  "username": "Ding♫ Dong♫", "icon_emoji": ":alarm_clock:"}' $url	
			eventtime=`date +%s`
		else 
			message="no new data file"  
	fi


	if [[ -n $message2 ]]  # restart session
		then 
			message2="$message2 Thanks."
			echo "$message2"
			curl -X POST -H 'Content-type: application/json' --data '{"text": "'"$message2"'",  "username": "Ding♫ Dong♫", "icon_emoji": ":sos:"}' $url 			eventtime=`date +%s`
		else 
			message="Session finishied."  
	fi


	if [[ -n $message3 ]] # check spout
		then 
			message3="$message3 Thanks."
			echo "$message3"

			curl -X POST -H 'Content-type: application/json' --data '{"text": "'"$message3"'",  "username": "Ding♫ Dong♫", "icon_emoji": ":checkered_flag:"}' https://hooks.slack.com/services/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 # lab_notes
			eventtime=`date +%s`
		else 
			message="Lick counts seem fine."  
	fi



# log and wait
	dt=`date -I'minutes'`
	echo "$dt $message" >>$logfile
	hr=`date +"%H"`
	if [[ $hr -lt 7 ]] 
		then 
			sleep 3600 
	elif [[ $hr -gt 19 ]]
		then
			sleep 3
	else 
			sleep 120 
	fi
done

##curl -X POST -H 'Content-type: application/json' --data '{"text": "'"$message"'",  "username": "DingDong!", "icon_emoji": ":alarm_clock:"}'  https://hooks.slack.com/services/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	#testing	
