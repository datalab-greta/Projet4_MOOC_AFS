#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Oct 21 13:33:36 2019

@author: oem
"""

import libarchive
import json
import pprint
import ast
filename = "/home/oem/Desktop/projet_mooc/archives_mooc/CNAM_01002_Trimestre_1_2014.7z"

#Pour extraire une archive dans le répertoire actuel:
extract_7z = libarchive.extract_file(filename)

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