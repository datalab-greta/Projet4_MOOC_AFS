#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Oct 10 11:04:10 2019

@author: alidata
"""

import pprint, os
import glob
import zipfile
from pymongo import MongoClient # librairie qui va bien
import configparser
import ast
import tarfile, rarfile #Extraire le contenu d'une archive .tar ou .rar


config = configparser.ConfigParser()
config.read_file(open(os.path.expanduser("~/.datalab.cnf")))

#DECLARATION DE L'INFRA A CONNECTER BDD MONGO
CNF = "mongodb"
BDD = "Datalab"

# Ouverture connection -> mongo sur serveur     AVEC LE HOST DANS FICHIER .CONF
client = MongoClient('mongodb://%s:%s@%s/?authSource=%s' % (config[CNF]['user'], config[CNF]['password'], config[CNF]['host'], BDD))
print(client)

collec = client['MOOC_GRP_AFS']['archive_7zip'] # ['archives']

fichier = sorted(glob.glob('/home/alidata/Bureau/projet_mooc/archives/*zip'))
print(fichier)
############ EN DEZIPE ###################################
for fil in fichier:
    print("-"+fil)
    zf = zipfile.ZipFile(fil, 'r') # le ZIP
    print(zf)

    for zipName in zf.namelist():
        try:
      
            x = ast.literal_eval(zf.read(zipName).decode("utf-8"))
            pprint.pprint(x)
        
            collec.insert_one(x)
        except SyntaxError:
            print('bbb')
            
