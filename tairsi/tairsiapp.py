#!/usr/bin/python

"""
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.

    Version 1.3
"""

import sys
import re
import requests
import yaml
from flask import Flask, render_template, redirect, request

configFile = "/etc/tairsi/tairsi.yml"
keyregex = re.compile('\w{30}')
numregex = re.compile('\d{11}')
keyvalid = "0"
numvalid = "0"
hckeyvalid = "0"

# Open configuration file and load configuration ------------------------------#
with open(configFile, 'r') as ymlfile:
    cfg = yaml.safe_load(ymlfile)

apikey = cfg['apiKey']
context = cfg['context']
endpoint = cfg['endpoint']
monitorkey = cfg['monitorkey']
gwhost = cfg['gwhost']
gwport = cfg['gwport']
priority = cfg['priority']
tarsaikey = cfg['tarsaikey']
sipendpoint = cfg['sipendpoint']

# Start application -----------------------------------------------------------#
app = Flask(__name__)

@app.route('/')
def homepage():
    return render_template("index.html", title="Tarsai")

@app.route('/poll', methods=['GET', 'POST'])
def pollapp():

    pollkey = request.args.get('key')
    pollnum = request.args.get('num')
    smsdata = request.args.get('smscontent')

    keycheck = keyregex.match(pollkey)
    numcheck = numregex.match(pollnum)

    if keycheck is None:
        print("Error processing the submitted key, it is not a 32 character key")
        sys.exit(1)
    else:
        keyvalid = "true"

    if numcheck is None:
        print("Invalid phone number specified")
        sys.exit(1)
    else:
        extension = ('77' + pollnum)
        numvalid = "true"

    if pollkey == tarsaikey and keyvalid and numvalid:

        pollapi(extension,smsdata)

    else:
        print("Incorrect API key or number specified, not calling extension, specified \
               phone number is ", extension)

    return redirect("/tairsi/", code=302)

@app.route('/healthcheck')
def healthcheckpage():

    """This page calls the healthcheck function in the backend to verify that
    the asterisk service is operating correctly"""

    hckey = request.args.get('key')

    try:
        keyregex.match(hckey)
        hckeyvalid = "true"
    except:
        return "Error processing the healthcheck key, please verify is 32 characters"
        sys.exit(1)

    if hckey == monitorkey and hckeyvalid:
        healthdata = healthcheck()
    else:
        healthdata = "Error, invalid healcheck key provided"
        print(healthdata)

    return healthdata

if __name__ == "__main__":
    app.run()

def pollapi(extension,smsdata):

    pollURL = ('http://' + gwhost + ':' + gwport + '/ari/channels?api_key=' + apikey +
               '&endpoint=' + endpoint + '&context=' + context +
               '&extension=' + extension + '&priority=' + priority + '&callerId=' + smsdata)

    requests.post(pollURL)

    print("Polling of Asterisk complete")

def healthcheck():
    """Healthcheck function polls Asterisk endpoint to verify that end to end
       functionality is working"""

    try:
        healthURL = ('http://' + gwhost + ':' + gwport + '/ari/endpoints/SIP/' + 
                     sipendpoint + '?api_key=' + apikey)
        healthjson = requests.get(healthURL).json()

        healthdata = healthjson['state']

    except:
        healthdata = "Healthcheck failed"

    return healthdata
