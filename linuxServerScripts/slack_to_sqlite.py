#!/usr/bin/env python
# coding: utf-8
# Author: Hakan Gunturkun
# Modified by: Hao Chen

import os
import re
import sqlite3
from sqlite3 import Error
import datetime

# entry file location
slackData = open('slash_rats.tab', 'r')

# db location and names
u01_database = r"menthol_u01.sqlite"
p50_database = r"HSRats2.sqlite"

# connect to db
def create_connection(db_file):
    conn = None
    try:
        conn = sqlite3.connect(db_file)
    except Error as err:
        print(err)
    return conn

# select from db
def select_query(conn, query):
    cur = conn.cursor()
    cur.execute(query)

    rows = cur.fetchall()
    found =[]
    for row in rows:
        found.append(row)
        #print(row)
    return found

def update_entry(conn, task):
    cur = conn.cursor()
    cur.execute(task)
    results=cur.fetchall()
    return cur.lastrowid

# activate db
conn_u01 = create_connection(u01_database)
conn_p50 = create_connection(p50_database)

# select rat_ids 
with conn_u01:
    query  = "SELECT RatID FROM Exp_JugularLineTests"
    u01_rats_query = select_query(conn_u01, query)

with conn_p50:
    query  = "SELECT RatID FROM Exp_JugularLineTests"
    p50_rats_query = select_query(conn_p50, query)


# create two lists for u01 and p50 rat_ids
u01_rats = []
p50_rats = []
for i in range(len(u01_rats_query)):
    u01_rats.append(u01_rats_query[i][0])

for i in range(len(p50_rats_query)):
    p50_rats.append(p50_rats_query[i][0])

print("u01 surgery rat count:" + str(len(u01_rats)))
print("p50 surgery rat count:" + str(len(p50_rats)))
#print(u01_rats)

today = datetime.date.today()
yesterday = today - datetime.timedelta(days=2)

tech_dict = {'Hao Chen' : 'HC',
        'First Last': 'User1'
       }

p50_added=''
u01_added=''
message=''

# i=2 for yesterday and today
for i in range(2):
    yesterday = str(today - datetime.timedelta(days=i))
    print ("checking brevital record for "+  yesterday + "\n")
    slackData.seek(0)
    for line in slackData:
        (tech, date, time, rat_id, note)=line.split("\t")
        if yesterday == date and re.search("brevital", note, re.I):
            if tech in tech_dict.keys():
                tech = tech_dict[tech]
            else:
                message +="This tech is not in the database: " + tech.lower() + "\n"
            if re.search('(pass|open)', note, re.I ):
                include = 'Y'
            elif re.search('(fail|block)', note, re.I):
                include = 'N'
            else:
                vagueBrevitalRatID += rat_id + " "
            if rat_id in u01_rats:
                task_sentence = "update Exp_JugularLineTests set Date=\""+date+"\",IncludeRat=\""+include+"\",TestBy=\""+tech+"\",Note=\""+note+"\" where RatID==\""+rat_id+"\""
                with conn_u01:
                    task = str(task_sentence)
                    update_entry(conn_u01, task)
                u01_added += rat_id + " "
            elif rat_id in p50_rats:
                task_sentence = "update Exp_JugularLineTests set Date=\""+date+"\",IncludeRat=\""+include+"\",TestBy=\""+tech+"\",Note=\""+note+"\" where RatID==\""+rat_id+"\""
                with conn_p50:
                    task = str(task_sentence)
                    update_entry(conn_p50, task)
                p50_added += rat_id + " "
            else:
                message += "The following rat_id is not found in the Exp_JugularLineTest: " + rat_id + "\n"

if (p50_added):
    message += "The brevital records of the following P50 rats have been added to the database: " +  p50_added + "\n"

if (u01_added):
    message += "The brevital records of the following U01 rats have been added to the database: " +  u01_added + "\n"

print (message)

if (message):
    url="https://hooks.slack.com/services/"; # labnotes;
    command = "curl -X POST -H 'Content-type: application/json' --data '{\"text\":" + "\"" + message + "\"" + ", \"channel\": \"#labnotes\", \"hao\": \"Analyst Jr.\", \"icon_emoji\": \":chart_with_upwards_trend:\"}'" +  " " + url
    os.system(command)

