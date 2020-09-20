#!/usr/bin/python

from flask import Flask
from flask import request
from flask import jsonify
import os
from datetime import datetime
import time
import re
from fuzzywuzzy import fuzz

app = Flask(__name__)
@app.route('/note', methods=['POST'])


def note():
	token=request.form['token']
	text=request.form['text']
	text=re.sub(r'\s+', " ", text)
	text=re.sub(r'\'', "\\\'", text)
	if (token=='iDX4PFAREtMS1jjTxQPC6ww7') :
		userdict = {    'U04SKCPC3': "User0",
				'U04S1JJ5G': "User1",
				'U16U9PY72': "User2",
                                'U73CFGP5J': "User3",
                                'UHHN2P2SH': "User4",
                                'UKKUWUQ21': "User5"

			}
		user=request.form['user_id']
		if (user in userdict):
			user=userdict[user]
			if (user == 'medpc'):
				searchObj=re.search(r'@(\w*)', text)
				if searchObj:
					user=searchObj.group(1)
				else:
					msg="You are using the lab account. Please include your user name in the message, like @hao,  and try again"
					return msg
		else:
			msg="I don't know who you are. Please ask @hao to add you to the user list."
			return msg

		#date=datetime.date.today()
                now = datetime.now()
                date = now.strftime("%Y-%m-%d\t%H:%M:%S")
		epoc=int(time.time())
		text=re.sub(r'\s*\@\w+\s*|^\s*|\s*$', "", text)
		Activities=[    'COVID ',
                                'made nicotine',
				'made cs2',
				'made heparin',
				'made menthol',
                                'made baytril',
                                'made carprofen',
				'deiced -80 freezer',
				'EtOH washed H chamber nicotine tubing',
				'EtOH washed J chamber nicotine tubing',
				'cleaned J chambers with peroxigard',
				'cleaned K chambers with peroxigard',
				'cleaned H chambers with peroxigard',
				'cleaned L chambers with peroxigard',
				'replaced H chamber nicotine syringes',
				'replaced J chamber nicotine syringes',
				'replaced H chamber bedding',
				'replaced J chamber bedding',
				'replaced H chamber sacgrp tubes',
				'replaced J chamber sacgrp tubes',
				'replaced H chamber spouts',
				'replaced J chamber spouts',
                                'box boxid comment',
                                'boxes boxid comment',
				'rat last_4_RFID comment',
				'rats [id1, id2] comment']
		#help message
		helpmsg='You can say:\n'
		for k in sorted(Activities):
			helpmsg=helpmsg + '>' + k + "\n"
		if text == 'help':
			msg=helpmsg
		elif re.search(r'COVID\s', text.upper(), re.I) is not None:
			covidfile="/root/Dropbox/Pies/covid_book.tab"
                        covidbook=open(covidfile,'a')
                        msg1 = user + "\t"  + date + "\t" + text + "\n"
                        covidbook.write(msg1)
	                msg = "Thanks for recording this. Be safe."
		elif re.search(r'box', text.upper(), re.I) is not None:
                        msg1 = user + "\t"  + date + "\t" + text + "\n"
			filename="/root/Dropbox/Pies/slash_book.tab"
			book=open(filename,'a')
			book.write(msg1)
			book.close()
	                msg = "Thanks for recording this."
		elif text.upper() in [x.upper() for x in Activities] :
			msg = "Thank you, "+ user +  ". I've logged that into the books."
			msg1 = user + "\t"+  text + "\t" + str(date) + "\t" +  str(epoc) + "\n"
			filename="/root/Dropbox/Pies/slash_book.tab"
			book=open(filename,'a')
			book.write(msg1)
			book.close()
		elif re.search(r'rat\s', text, re.I) is not None:
			rat=re.search(r'rat\s*(\w*)', text, re.I)
			rat=rat.group(1)
			rat=rat.upper()
			animalidfile='/root/Dropbox/medpc/animalids.tab'
			with open(animalidfile) as fin:
				rows=(line.split('\t') for line in fin)
				ratid={row[0]:row[1] for row in rows}
			if rat in ratid:
				rat=ratid[rat]
				rat=re.sub(r'\n', '', rat)
				msg1 = user + "\t"+   str(date) +"\t"+ rat+"\t"+ text + "\n" ## need full length ratid and check them again the animalid file
				msg = "Thank you, " + user +  ". I've logged your entry about rat "+ rat
				filename="/root/Dropbox/Pies/slash_rats.tab"
				book=open(filename,'a')
				book.write(msg1)
				book.close()
			else:
				msg="I don't know about that rat. Can you check please? You can enter a regular slack message if you are sure this is the correct one."
				return msg;
		elif re.search(r'rats\s', text, re.I) is not None:
			rats=re.match(r'rats\s+\[(.*)\]', text, re.I)
			if rats is None:
				msg="Please put multiple rat IDs in square brackets. For example  [bnf1, 001f]."
				return msg;
			rats=rats.group(1)
			rats=rats.upper()
			rats=re.sub(r',+|\s+', ' ', rats)
			rats=rats.split()
			text=re.sub(r'rats\s*|\[.*\]\s*', '', text)
			animalidfile='/root/Dropbox/medpc/animalids.tab'
			knownRats=''
			unknownRats=''
			with open(animalidfile) as fin:
				rows=(line.split('\t') for line in fin)
				ratid={row[0]:row[1] for row in rows}
			for rat in rats:
				if rat in ratid:
					knownRat=ratid[rat]
					knownRat=re.sub(r'\n', '', knownRat)
					#msg1 = user + "\t"+   str(1990-10-10) +"\t"+ knownRat+"\t"+ text + "\n" 
					msg1 = user + "\t"+   str(date) +"\t"+ knownRat+"\t"+ text + "\n"
					knownRats+=" " + knownRat
					filename="/root/Dropbox/Pies/slash_rats.tab"
					book=open(filename,'a')
					book.write(msg1)
					book.close()
				else:
					unknownRats+=" "+rat
			if knownRats:
				msg = "Thank you, " + user +  ". I've logged your comments for "+ knownRats +"."
				if unknownRats:
					msg+=" However, I _don't_ know about *" + unknownRats + "*. Can you please check the IDs?"
			elif unknownRats:
				msg = "Sorry. I _don't_ know about *" + unknownRats +"*. Can you please check the IDs?"
		else:
			text=re.sub(r'box', 'chamber', text, re.I)
			text=re.sub(r'boxes', 'chamber', text, re.I)
			text=re.sub(r'changed', 'replaced', text, re.I)
			text=re.sub(r'sacgrape', 'sacgrp', text, re.I)
			text=re.sub(r'saccgrape', 'sacgrp', text, re.I)
			text=re.sub(r' for ', ' ', text, re.I)
			maxscore=80
			for i in Activities:
				score=fuzz.token_sort_ratio(text.upper(), i.upper())
				if score > maxscore:
					similar=i
					maxscore=score
			if maxscore>80:
				msg="What you said is similar to *"+ similar + "*. I've record that in the books. If that is _not_ what you meant, please let @hao know."
				msg1 = user + "\t"+ similar + "\t" + str(date) + "\t" +  str(epoc) + "\n"
				filename="/root/Dropbox/Pies/slash_book.tab"
				book=open(filename,'a')
				book.write(msg1)
				book.close()
			else:
				msg = "You said: |"+ text+"| Sorry I don't know how to record that yet. " + helpmsg
		return jsonify(text=msg, response_type="in_channel")

if __name__ == '__main__':
	port = int(os.environ.get('PORT', 5000))
	app.run(host="provide.your.host.here", port=port, debug=True)


