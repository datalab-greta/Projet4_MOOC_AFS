#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Oct 21 17:00:31 2019

@author: perrot
"""

from sqlalchemy import create_engine
from sqlalchemy.sql import text
import os
from pymongo import MongoClient # librairie qui va bien
import configparser

config = configparser.ConfigParser()
config.read_file(open(os.path.expanduser("~/datalab.cnf")))

CNF = "mongo"
BDD = "Datalab"


# Ouverture connection -> mongo sur serveur
client = MongoClient('mongodb://%s:%s@%s/?authSource=%s' % (config[CNF]['user'], config[CNF]['password'], config[CNF]['host'], BDD))
print(client)

bdd = client['MOOC_GRP_AFS'] # BDD "Datalab" de mongoDB sur serveur
bdd
print("'MOOC_GRP_AFS' Collections:")
for cn in bdd.list_collection_names():
    print("-"+cn)
collec = client['MOOC_GRP_AFS']['Fun_Mooc5']

TBL = "Fun_Mooc1"
CNF2 = "pgBDD"
pgSQLengine = create_engine("postgresql://%s:%s@%s/%s" % (config[CNF2]['user'], config[CNF2]['password'], config[CNF2]['host'], "BDD_Franck"))
print(pgSQLengine)
pgSQLengine.execute("TRUNCATE \"%s\";" % TBL)
pgSQLengine.execute("""CREATE TABLE IF NOT EXISTS "Fun_Mooc1"(
   id character (100)  NOT NULL,
   course_id character (100)  NOT NULL,
   courseware_title character (100),
   date Timestamp (50),
   user_id character (32),
   username character (355)  NOT NULL,
   title character (55),
   body character (5000)  NOT NULL,
   blen integer,
   resp_total integer,
   thread_type character (52),
   mtype character (100),
   thread_id character (32),
   parent_id character (32),
   endorsed character (10)


);""")

statement = text("""
INSERT INTO "Fun_Mooc1" (id, course_id, courseware_title, date, user_id, username, title, body, blen, resp_total,thread_type,mtype,thread_id,parent_id,endorsed)
VALUES (:id, :cid, :courseware_title, :date, :user_id, :username, :title, :body, :l, :resp_total,:thread_type,:mtype,:thread_id,:parent_id,:endorsed)""")
#~ exit()

bdd = client['MOOC_GRP_AFS'] # BDD "Datalab" de mongoDB sur serveur
bdd
#~ print("'Datalab' Collections:")
#~ for cn in bdd.list_collection_names():
    #~ print("-"+cn)
collec = client['MOOC_GRP_AFS']['Fun_Mooc5']



NivMax = 0

def applat(mesg, niv):
    global NivMax
    l = len(mesg['body'])
    username = 'Anonymous'
    if 'username' in mesg: username = mesg['username'][:50]
    #c = len(mesg['endorsed_responses']+mesg['non_endorsed_responses'])
    user_id = ''
    if 'user_id' in mesg: user_id = mesg['user_id'][:50]
    title = '?'
    if 'title' in mesg: title = mesg['title'][:50]
    resp_total = 0
    if 'resp_total' in mesg: resp_total = mesg['resp_total']
    thread_id = ''
    if 'thread_id' in mesg: thread_id = mesg['thread_id']
    thread_type =''
    if 'thread_type' in mesg: thread_type = mesg['thread_type'][:52]
    endorsed = ''
    if 'endorsed' in mesg: endorsed = mesg['endorsed']
    parent_id =''
    if 'parent_id' in mesg: parent_id = mesg['parent_id']
    mtype =''
    if 'type' in mesg:  mtype = mesg['type'][:52]
    courseware_title =''
    if 'courseware_title' in mesg:  mtype = mesg['courseware_title'][:100]
#    votecount = 0
#    if 'vote.count' in mesg:  votecount = mesg['vote.count']
    
    pgSQLengine.execute(statement, id=mesg['id'], cid=mesg['course_id'], date=mesg['updated_at'], user_id=user_id, username=username, body=mesg['body'][:5000], l = len(mesg['body']), 
                        title=title, resp_total=resp_total,thread_id=thread_id,thread_type=thread_type,endorsed=endorsed,parent_id=parent_id,
                        mtype=mtype,courseware_title=courseware_title)

    childs = [] # liste des enfants
    if 'children' in mesg: childs += mesg['children']
    if 'endorsed_responses' in mesg: childs += mesg['endorsed_responses']
    if 'non_endorsed_responses' in mesg: childs += mesg['non_endorsed_responses']
    for child in childs:
#        applat(child+l, niv+1)
        l+=applat(child,niv+1)
    #print("nombre de caractères cumulés ",l)
    if niv > NivMax:
        NivMax = niv
    print("%s %s %s : %s = %d,%d" % ("  "*niv, mesg['course_id'], mesg['updated_at'], username,len(mesg['body']),l))
    return l


cursor = collec.find()
for doc in cursor:
    if 'content' in doc:
        #~ pprint.pprint(doc)
        print("-------------------------------")
        longueur = applat(doc['content'], 0)
        #~ print(longueur)
        
print("Niv max=%d" % NivMax)



