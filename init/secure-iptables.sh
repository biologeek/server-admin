#!/bin/bash

#################################################################################
#	Ready to use shell script to secure server ports access via iptables		#
#-------------------------------------------------------------------------------#
#	Version		|		Author		|					Comment					#
#-------------------------------------------------------------------------------#
#																				#
#																				#
#################################################################################


ME="`whoami`"
IPTABLES_FILE=/etc/iptables-secure.rules
MASTER_IPTABLES=/etc/network/if-pre-up.d/iptables

RKHUNTER_CONF=/etc/default/rkhunter
REPORT_EMAIL



if [ $ME != "root" ]
	then 
	echo "You should be root to launch this script !!"
	exit 1
fi


echo "***************************************"
echo "**	Configuring iptables"
echo "***************************************"

echo "Writing rules for iptables in $IPTABLES_FILE..."


echo "Checking if iptables installed..."

iptables --version
if [ $? -eq 0 ]
	then
	echo "Iptables installed !"
fi


touch $IPTABLES_FILE

if [ $? -ne 0 ]
	then 
	echo "*** Could not write to $IPTABLES_FILE !!"
	exit 1
fi

chmod 775 $IPTABLES_FILE

echo "*filter" >> $IPTABLES_FILE
echo "# Empty current tables" >> $IPTABLES_FILE
echo "-F " >> $IPTABLES_FILE
echo "# Empty personal rules" >> $IPTABLES_FILE
echo "-X " >> $IPTABLES_FILE
echo "# ---" >> $IPTABLES_FILE
echo "# Don't break current connections" >> $IPTABLES_FILE
echo "-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT " >> $IPTABLES_FILE
echo "-A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT " >> $IPTABLES_FILE
echo "# Authorize loopback" >> $IPTABLES_FILE
echo "-A INPUT -i lo -j ACCEPT " >> $IPTABLES_FILE
echo "-A OUTPUT -o lo -j ACCEPT " >> $IPTABLES_FILE
echo "# ICMP (Ping)" >> $IPTABLES_FILE
echo "-A INPUT -p icmp -j ACCEPT " >> $IPTABLES_FILE
echo "-A OUTPUT -p icmp -j ACCEPT " >> $IPTABLES_FILE
echo "# SSH In" >> $IPTABLES_FILE
echo "-A INPUT -p tcp --dport 22 -j ACCEPT " >> $IPTABLES_FILE
echo "# SSH Out" >> $IPTABLES_FILE
echo "-A OUTPUT -p tcp --dport 22 -j ACCEPT " >> $IPTABLES_FILE
echo "# DNS In/Out" >> $IPTABLES_FILE
echo "-A OUTPUT -p tcp --dport 53 -j ACCEPT " >> $IPTABLES_FILE
echo "-A OUTPUT -p udp --dport 53 -j ACCEPT " >> $IPTABLES_FILE
echo "-A INPUT -p tcp --dport 53 -j ACCEPT " >> $IPTABLES_FILE
echo "-A INPUT -p udp --dport 53 -j ACCEPT " >> $IPTABLES_FILE
echo "# NTP Out" >> $IPTABLES_FILE
echo "-A OUTPUT -p udp --dport 123 -j ACCEPT " >> $IPTABLES_FILE
echo "-A OUTPUT -p tcp --dport 80 -j ACCEPT " >> $IPTABLES_FILE
echo "-A OUTPUT -p tcp --dport 443 -j ACCEPT " >> $IPTABLES_FILE
echo "# HTTP + HTTPS In" >> $IPTABLES_FILE
echo "-A INPUT -p tcp --dport 80 -j ACCEPT " >> $IPTABLES_FILE
echo "-A INPUT -p tcp --dport 443 -j ACCEPT " >> $IPTABLES_FILE
echo "-A INPUT -p tcp --dport 8443 -j ACCEPT " >> $IPTABLES_FILE
echo "-A OUTPUT -p tcp --syn -m limit --limit 100/min -j ACCEPT " >> $IPTABLES_FILE
echo "-A OUTPUT -p tcp --syn -m limit --limit 1000/min -j LOG --log-prefix \"-Dropped: \" --log-level 4 " >> $IPTABLES_FILE
echo "-A OUTPUT -p tcp --syn -j REJECT --reject-with tcp-reset " >> $IPTABLES_FILE
echo "# Drop non SYN packages at tcp connection and all malformed packets" >> $IPTABLES_FILE
echo "-A INPUT -p tcp ! --syn -m state --state NEW -j DROP" >> $IPTABLES_FILE
echo "-A INPUT -p tcp --tcp-flags ALL NONE -j DROP" >> $IPTABLES_FILE
echo "-A INPUT -p tcp --tcp-flags ALL ALL -j DROP" >> $IPTABLES_FILE
echo "-A INPUT -f -j DROP" >> $IPTABLES_FILE
echo "# By default forbid all input and output connections" >> $IPTABLES_FILE
echo "-P INPUT DROP " >> $IPTABLES_FILE
echo "-P FORWARD DROP " >> $IPTABLES_FILE
echo "-P OUTPUT DROP " >> $IPTABLES_FILE
echo "COMMIT" >> $IPTABLES_FILE


echo "OK, finished to write custom iptables rules..."

echo "Activating new rules..."

iptables-restore < $IPTABLES_FILE


iptables -L



read -p " Are you happy with these new rules (before pushing them to master iptables) ? [Y/n]" QUESTION

if [ "$QUESTION" == "y" || "$QUESTION" == "yes" || "$QUESTION" == "" ]
	then

	iptables-save > $IPTABLES_FILE
	echo "#!/bin/bash" > $MASTER_IPTABLES
	echo "iptables-restore < $IPTABLES_FILE" > $MASTER_IPTABLES
	echo "Installing automatic reload of rules at startup..."
	chmod +x $MASTER_IPTABLES
else 
	echo "Okay, we'll not install it then..."
fi


echo "***************************************"
echo "**	Installing fail2ban"
echo "***************************************"



apt-get install fail2ban
RES=$?

if [ $RES -ne 0 ]
	then 
	echo "** Error during fail2ban install !!"
fi



echo "***************************************"
echo "**	Installing Rootkit hunter"
echo "***************************************"


apt-get install rkhunter
RES=$?

if [ $RES -ne 0 ]
	then 
	echo "** Error during Rootkit hunter install !!"
fi


read -p "Mail address to which send rootkit alerts ? " EMAIL_ADDRESS

STR="`grep REPORT_EMAIL $RKHUNTER_CONF`"

sed -i "s/$STR/REPORT_EMAIL=\"$EMAIL_ADDRESS\"/g" $RKHUNTER_CONF

STR="`grep CRON_DAILY_RUN $RKHUNTER_CONF`"
sed -i "s/$STR/CRON_DAILY_RUN=\"yes\"/g" $RKHUNTER_CONF
