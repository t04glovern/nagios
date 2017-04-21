#!/bin/bash
# Script to install and configure Nagios NRPE for the local system
# Created and maintained by Nathan Glover (2017)

echo "Updating apt repo prior to installing NRPE plugins"
/usr/bin/apt-get update

echo "Installing nagios plugins and NRPE server"
/usr/bin/apt-get -y install nagios-plugins nagios-nrpe-server

echo "Type the IP address of the Nagios Server, followed by [ENTER]:"
read nagiosip
while true; do
        read -p "To confirm, your Nagios server IP is ${nagiosip}? [y/n]" yn
        case $yn in
                [Yy]* ) break;;
                [Nn]* ) echo "Please re-run the script with the correct input"; exit;;
                * ) echo "Please answer y/n.";;
        esac
done

echo "Writing ${nagiosip} to allowed_host field in /etc/nagios/nrpe.cfg"
original_line="allowed_hosts=127.0.0.1"
new_line="allowed_hosts=127.0.0.1,${nagiosip}"
sed -i "s%$original_line%$new_line%g" /etc/nagios/nrpe.cfg

echo "Installing Nagios NRPE plugin for apt-get update monitoring"
/usr/bin/apt-get -y install nagios-nrpe-plugin

echo "Adding check_apt definition to /etc/nagios/nrpe_local.cfg file"
grep -q -F 'command[check_apt]=/usr/lib/nagios/plugins/check_apt' /etc/nagios/nrpe_local.cfg || echo 'command[check_apt]=/usr/lib/nagios/plugins/check_apt' >> /etc/nagios/nrpe_local.cfg

echo "Restarting the NRPE service..."
service nagios-nrpe-server restart

echo "System configured with basic Nagios NRPE services. add a new host on the Nagios server to begind mornitoring"
