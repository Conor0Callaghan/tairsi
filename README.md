# Tairsi 

## What is Tairsi? 

Tairsi is a simple gateway written in Python, it aims to segregate an application or service from an Asterisk server. 

## Tairsi requirements & setup

There are a number of requirements to run Tairsi, this can probably be squashed into a set of simple containers. 

  * CentOS7
  * python3 
  * virtual env
  * httpd 2.4
  * mod_wsgi
  * python-requests installed in the virtualenv 

### Setup steps

The setup script contained in the repository creates a simple setup of the application and places a sample configuration in /etc/tairsi . The sample configuration **must be changed** prior to using the application or it simply won't work. 

  1. Install the pre-reqs above
  2. Run the setup script in the repository with elevated privileges
  3. Create a virtual environment in tairsi/venv and install python requests in the virtualenv
  3. Modify the sample configuration in /etc/tairsi.yml and the /var/www/app/tairsi.wsgi configuration to suit your requirements
  4. Test the application by polling your server at `http(s)://yourserver/poll?key=dasdAGAERGARV32ECSAC&number=+447654321011&smscontent="bad things are happening"` and monitor server logs for any errors **mod_wsgi** config has an IP whitelist in the configuration.

## Tairsi operation

The following is a simple step by step of how Tairsi was designed to work. 

  1. It accepts a HTTP(S) poll to it's */poll* endpoint [requires an API key (key), phone number target of alert (number) and details for an SMS alert (smscontent]
  2. The poll contents are verified and an onward poll is made to the Asterisk server containing the phone number and sms alert contents.  

## How does it run? 

The application runs in Apache HTTPD using mod_wsgi. A sample configuration file tairsi.wsgi is available in this repository.  

## Simple healthcheck 

The code repository contains a simple Zabbix template which can be imported to a Zabbix server and applied to a host which has network connectivity to the API interface. 

## CAUTIONS

The use of the smscontent field is experimental. This places freeform text in the callerid field, which you can them make use of inside your dialplan for other puproses. This has the potential for code injection issues if not validated, use at your own risk !

## To Do

There are a few things on the backlog

  * Test with HTTPS   
  * Test with nginx
  * Find alternative methods for SMS

## Authors

  * Conor O'Callaghan - [@ivernus](https://github.com/ivernus/)
  * Glenn Ambler - [@gambler2073](https://github.com/gambler2073/)
