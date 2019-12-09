#!/bin/sh

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

version="1.3"
overwrite="false"
apache_config_dir="/etc/httpd/conf.d"
app_install_dir="/var/www/app"
tairsi_install_dir="/var/www/app/tairsi"
prereqs="mod_wsgi python-requests httpd"
etctairsi="/etc/tairsi"

# Check that httpd is already installed, otherwise exit
httpd_check=$(rpm -qa | grep -c "httpd-[0-9]*")

clear

function lineprint()
{
    echo "--------------------------------------------------------------------------------"
    echo -e "\e[35m${1}\e[0m"
    echo "--------------------------------------------------------------------------------"
}

# Check to see if the user has elevated permissions
if [ $(whoami) != "root" ]; then
    echo "ERROR: You must run this script as root"
    exit 1
fi

# Exit if there is no httpd installed 
if [ ${httpd_check} -eq 0 ]; then
    echo "ERROR: No httpd installed, exiting..."
    exit 1
fi

# Starting install ------------------------------------------------------------#

lineprint "Checking pre-requisite packages"

# Check for and install packages - prereqs 
for requisite in ${prereqs}; do

    # A crude check of the RPM database
    echo -en "Checking package ${requisite} "

    checkcount=$(rpm -qa | grep -c -i "${requisite}-[0-9].")

    if [ ${checkcount} -lt 1 ]; then
      echo -e "\e[101mNOT FOUND\e[0m exiting"
      exit 1
    else
      echo -e "\e[42mFOUND\e[0m"
    fi
done

# Dump httpd config template
lineprint "Installing configuration template"

# Check if the configuration already exists
if [ -f ${apache_config_dir}/tairsi.conf ];
then 
    echo -e "\e[42mOK\e[0m HTTPD Config for tairsi already exists, skipping"
else
    echo "Copying tairsi.conf HTTPD config to ${apache_config_dir}"
    cp -rv tairsi.conf ${apache_config_dir}
fi

# Drop configuration in /etc
mkdir -p ${etctairsi} 

if [ -f ${etctairsi}/tairsi.yml ];
then 
    echo -e "\e[42mOK\e[0m Tairsi configuration already in place at ${etctairsi}, skipping"
else
    echo "Copying tairsi.yml to ${etctairsi}"
    cp tairsi.yml ${etctairsi}
fi

# v1.3 Check for monitoring key and SIP endpoint in configuration 
if cat ${etctairsi}/tairsi.yml | grep -qi monitorkey;
then
    echo -e "\e[42mOK\e[0m Tairsi monitor key is already in place, skipping"
else
    echo -e "\e[46mINSTALL\e[0m Adding monitorkey to the tairsi.yml file. SEE CHANGELOG"
    echo -en "\n# Monitoring key for availability monitor\nmonitorkey: \"CHANGEkeyto32characterskey\"\n" >> ${etctairsi}/tairsi.yml
    echo -e "\e[46mINSTALL\e[0m Adding SIP endpoint to the tairsi.yml file. SEE CHANGELOG"
    echo -en "\n# SIP Endpoint\nsipendpoint: \"555\"" >> ${etctairsi}/tairsi.yml
fi    

# Change permissions on configuration file
chown apache.apache ${etctairsi}/tairsi.yml
chmod 700 ${etctairsi}/tairsi.yml

lineprint "Installing application"

# Install application 
mkdir --verbose -p ${app_install_dir}
mkdir --verbose -p ${tairsi_install_dir}
cp -rf tairsi/* ${tairsi_install_dir}
cp -rf tairsi.wsgi ${app_install_dir} 

# Dump installer version to file
echo "$version" > ${tairsi_install_dir}/app-version

echo -e "Installation files in place, modify the httpd config in ${apache_config_dir},\nrestart httpd and test access http://localhost/tairsi using the parameters\ndetailed in the documentation"
echo "--------------------------------------------------------------------------------"
