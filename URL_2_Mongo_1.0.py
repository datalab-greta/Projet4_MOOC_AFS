#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Oct 17 16:40:11 2019
@author: rousseau
"""

import requests, os, re
from urllib import parse

from pymongo import MongoClient # librairie qui va bien
import configparser

config = configparser.ConfigParser()
config.read_file(open(os.path.expanduser("~/datalab.cnf")))

'''
[FUN]
user=email
password=password
URL=https://www.fun-mooc.fr/
[EDX]
user=email
password=password
URL=https://courses.edx.org/
'''

CNF = "mongo"
BDD = "Datalab"

MOOC='FUN' #~ base = "https://www.fun-mooc.fr/courses/"
course = "course-v1:UCA+107001+session02"
course = "course-v1:UPSUD+42001+session12"
course = "course-v1:MinesTelecom+04026+session05"
listURL = "/discussion/forum/?ajax=1&page=1&sort_key=date&sort_order=desc"

#~ MOOC='EDX' #~ base = "https://www.fun-mooc.fr/courses/"
#~ course = "course-v1:IMTx+DMx102+2T2018"


# Ouverture connection -> mongo sur serveur
client = MongoClient('mongodb://%s:%s@%s/?authSource=%s' % (config[CNF]['user'], config[CNF]['password'], config[CNF]['host'], BDD))
collec = client['MOOC_GRP_AFS']['Fun_URL']

# Recup 1er jeton (défaut)
response = requests.get(
    config[MOOC]['URL']+"login",
    headers={
        'Referer': config[MOOC]['URL']+'login'
    }
)
cookie = response.headers['Set-Cookie']
#~ print(cookie)
csrftoken = cookie[10:42]
csrftoken = re.sub(';.*', '', cookie[10:])
print("csrftoken TMP="+csrftoken)

# Recup 2er BON jeton (avec user & password)
info="email=%s&password=%s" % (parse.quote_plus(config[MOOC]['user']), parse.quote_plus(config[MOOC]['password']))
response = requests.post(
    config[MOOC]['URL']+"login_ajax",
    data=info,
    headers={
        #"Accept": "application/json, text/javascript, */*; q=0.01",
        "X-CSRFToken": csrftoken,
        #"X-Requested-With": "XMLHttpRequest",
        'Cookie': cookie, 
        'Referer': config[MOOC]['URL']+'login',
        #'User-Agent': 'Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:69.0) Gecko/20100101 Firefox/69.0',
        #'Accept-Encoding': 'gzip, deflate, br',
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
    }
)

cookie = response.headers['Set-Cookie']
print(cookie)
i = cookie.find('csrftoken=')
cookie = cookie[i+10:]
csrftoken = re.sub(';.*', '', cookie)
print("csrftoken OK="+csrftoken+".")
print(response.content)
print('---------------------------------------------------------')

# Récup de la liste (général) des fils
URL = config[MOOC]['URL']+"courses/"+course+listURL
referer = config[MOOC]['URL']+"courses/"+course+"/discussion/forum/"
print("URL: "+URL+"\nref:"+referer)


response = requests.get(
    URL,
    #~ params={'ajax': 1, 'resp_skip': 0, 'resp_limit': 25},
    headers={
        "User-Agent": "Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:69.0) Gecko/20100101 Firefox/69.0",
        "Accept": "application/json, text/javascript, */*; q=0.01",
        "Accept-Language": "en-US,en;q=0.5",
        "X-CSRFToken": csrftoken,
        "X-Requested-With": "XMLHttpRequest",
        'Referer': referer,
        'Cookie': cookie, 
        # EDX
        'Pragma': 'no-cache',
        'Cache-Control': 'no-cache',
    },
)

print(response.status_code)
print(response.content)
print(response.headers)
data = response.json()
#~ pprint.pprint(data)

for disc in data['discussion_data']:
    URL = disc['commentable_id']+"/threads/"+disc['id']
    print("%s [%d] %s" % (disc['id'], disc['comments_count'], disc['title']))
    response = requests.get(
        config[MOOC]['URL']+"courses/"+course+"/discussion/forum/"+URL,
        params={'ajax': 1, 'resp_skip': 0, 'resp_limit': 300},
        headers={
            #"User-Agent": "Mozilla/5.0 (X11; Ubuntu; Linux i686; rv:69.0) Gecko/20100101 Firefox/69.0",
            "Accept": "application/json, text/javascript, */*; q=0.01",
            #"Accept-Language": "en-US,en;q=0.5",
            "X-CSRFToken": csrftoken,
            "X-Requested-With": "XMLHttpRequest",
            #'Referer': 'https://www.fun-mooc.fr/courses/course-v1:MinesTelecom+04026+session05/discussion/forum/204c764cf87424d86a6259562d1d200afe30ab9a/threads/5d9481db1c89dcf269015b6f' ,
            'Cookie': cookie, #'defaultRes=2400%2C0; csrftoken=LvmImlOzFWNoC8oQbAdPUvlP7a4ab3KZ; __utma=218362510.833297836.1474796751.1542221217.1542232713.415; acceptCookieFun=on; atuserid=%7B%22name%22%3A%22atuserid%22%2C%22val%22%3A%2231d3b730-8db4-4c4b-9b98-be9e14c92513%22%2C%22options%22%3A%7B%22end%22%3A%222020-09-27T13%3A54%3A31.376Z%22%2C%22path%22%3A%22%2F%22%7D%7D; atidvisitor=%7B%22name%22%3A%22atidvisitor%22%2C%22val%22%3A%7B%22vrn%22%3A%22-602676-%22%7D%2C%22options%22%3A%7B%22path%22%3A%22%2F%22%2C%22session%22%3A15724800%2C%22end%22%3A15724800%7D%7D; sessionid=kyxq7top4gplpn8dinb5y1ez0wdg6hrl; edxloggedin=true; edx-user-info="{\"username\": \"EGo41\"\054 \"version\": 1\054 \"email\": \"emmanuel.goudot@gmail.com\"\054 \"header_urls\": {\"learner_profile\": \"https://www.fun-mooc.fr/u/EGo41\"\054 \"logout\": \"https://www.fun-mooc.fr/logout\"\054 \"account_settings\": \"https://www.fun-mooc.fr/account/settings\"}}"'
        },
    )
    print(response.content)
    fil = response.json()
    print(fil)
    collec.insert_one(fil)
