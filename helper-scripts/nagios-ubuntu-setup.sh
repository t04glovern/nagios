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
original_line_allowed_hosts="allowed_hosts=127.0.0.1,::1"
new_line_allowed_hosts="allowed_hosts=127.0.0.1,${nagiosip}"
sed -i "s%$original_line_allowed_hosts%$new_line_allowed_hosts%g" /etc/nagios/nrpe.cfg

echo "Enabling logging to /var/log/nrpe.log in /etc/nagios/nrpe.cfg"
original_line_logging="#log_file=/var/log/nrpe.log"
new_line_logging="log_file=/var/log/nrpe.log"
sed -i "s%$original_line_logging%$new_line_logging%g" /etc/nagios/nrpe.cfg
touch /var/log/nrpe.log

echo "Replacing disk command in /etc/nagios/nrpe.cfg"
original_line_check_disk="command[check_hda1]=/usr/lib/nagios/plugins/check_disk -w 20% -c 10% -p /dev/hda1"
new_line_check_disk="command[check_disk]=/usr/lib/nagios/plugins/check_disk -w 20% -c 10% -p /"
sed -i "s%$original_line_check_disk%$new_line_check_disk%g" /etc/nagios/nrpe.cfg

echo "Disabling SSL in /etc/default/nagios-nrpe-server"
original_line_ssl="#NRPE_OPTS=\"-n\""
new_line_ssl="NRPE_OPTS=\"-n\""
sed -i "s%$original_line_ssl%$new_line_ssl%g" /etc/default/nagios-nrpe-server

echo "Installing Nagios NRPE plugin for apt-get update monitoring"
#/usr/bin/apt-get -y install nagios-nrpe-plugin

echo "Adding check_apt definition to /etc/nagios/nrpe_local.cfg file"
grep -q -F 'command[check_apt]=/usr/lib/nagios/plugins/check_apt' /etc/nagios/nrpe_local.cfg || echo 'command[check_apt]=/usr/lib/nagios/plugins/check_apt' >> /etc/nagios/nrpe_local.cfg

echo "Restarting the NRPE service..."
service nagios-nrpe-server restart

echo "System configured with basic Nagios NRPE services. add a new host on the Nagios server to begind mornitoring"
