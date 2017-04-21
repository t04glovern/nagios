#!/bin/bash
# Script to configure/setup a new ubuntu server host for Nagios monitoring
# Created and maintained by Nathan Glover (2017)

echo "Type the Hostname of the Ubuntu Server, followed by [ENTER]:"
read nagioshostname
echo "Type the IP address of the Ubuntu Server, followed by [ENTER]:"
read nagiosip
echo "Type the Alias for the Ubuntu Server [Git Server 01], followed by [ENTER]:"
read nagiosalias

while true; do
        read -p "To confirm, your ${nagiosalias} ${nagioshostname} with the IP ${nagiosip}? [y/n]" yn
        case $yn in
                [Yy]* ) break;;
                [Nn]* ) echo "Please re-run the script with the correct input"; exit;;
                * ) echo "Please answer y/n.";;
        esac
done

hostfilepath="/usr/local/nagios/etc/objects/servers/${nagioshostname}.cfg"

echo "Creating new host configuration from template"
cp /usr/local/nagios/helper-scripts/nagios-ubuntu-template.cfg $hostfilepath

echo "Updating host configuration file with host details"
templatehost="PRODTEMPLATEHOST"
templatealias="PRODTEMPLATEALIAS"
templateip="PRODTEMPLATEIP"
sed -i "s%$templatehost%$nagioshostname%g" $hostfilepath
sed -i "s%$templatealias%$nagiosalias%g" $hostfilepath
sed -i "s%$templateip%$nagiosip%g" $hostfilepath

echo "Restart the Nagios Service"
service nagios restart
