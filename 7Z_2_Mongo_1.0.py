#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Oct 22 11:01:12 2019

@author: rousseau
"""

import requests, pprint, os
import libarchive
from pymongo import MongoClient # librairie qui va bien
import configparser
import sys, glob, zipfile, json, ast, demjson, pprint
#from demjson import decode


config = configparser.ConfigParser()
config.read_file(open(os.path.expanduser("~/datalab.cnf")))

CNF = "mongo"
BDD = "Datalab"

# Ouverture connection -> mongo sur serveur
client = MongoClient('mongodb://%s:%s@%s/?authSource=%s' % (config[CNF]['user'], config[CNF]['password'], config[CNF]['host'], BDD))
print(client)

bdd = client['Datalab'] # BDD "Datalab" de mongoDB sur serveur
bdd

collec = client['MOOC_GRP_AFS']['Fun_Mooc5']



print(list)
#~ exit()
collec.drop()
filename = "/home/rousseau/Projet4/CNAM_01002_Trimestre_1_2014.7z"

#Pour extraire une archive dans le répertoire actuel:
#extract_7z = libarchive.extract_file(filename)

#Pour lire une archive:
with libarchive.file_reader(filename) as archive:    
         for entry in archive:
             #print(entry)
             concate = b"" #encore en binaire
             for block in entry.get_blocks():
                 concate = concate+block
             #archive.write(block)
             print(concate)  
             encoded = concate.decode('utf-8')
             json7zip = ast.literal_eval(encoded)
             pprint.pprint(json7zip) 
             collec.insert_one(json7zip,{'ordered' : False})
             
#collec = client['MOOC_GRP_AFS']['Fun_Mooc5']

#~ exit()
#collec.drop()
#collec.rename("TestMongo")
