#!/bin/bash

#################################################################################
#	Ready to use shell script to secure apache server and implement SSL-only	#
#	connections																	#
#-------------------------------------------------------------------------------#
#	Version		|		Author		|					Comment					#
#-------------------------------------------------------------------------------#
#																				#
#																				#
#################################################################################



CRON_FILE=/etc/cron.d/eff-certbot-renewal




echo "Installing Certbot from Electronic Frontier Foundation..."
echo "Please visit https://certbot.eff.org/ for more information !"

apt-get install python-certbot-apache -t jessie-backports


echo "Adding regular job to Crontab for automatic renewal of certificate..."
echo "* * * * */3 certbot renew" > $CRON_FILE
echo "Installing new cron..."
crontab $CRON_FILE
