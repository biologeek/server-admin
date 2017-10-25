#!/bin/bash

#################################################################################
#	Shell script to dump databases to file										#
#-------------------------------------------------------------------------------#
#	Version		|		Author		|					Comment					#
#-------------------------------------------------------------------------------#
#	1.0			|					|											#
#-------------------------------------------------------------------------------#
#				|					|											#
#################################################################################

# File that contains configuration of databases to dump
CONFIG_FILE=dump.properties
PSQL_EXE=psql
MYSQL_EXE=mysql

export CONFIG_FILE



if [ -f $CONFIG_FILE ]
	then
	# Batch is already parametered. Sourcing config and starting dump
	. $CONFIG_FILE

else 
	###############################################################
	###						CONFIGURATION						###
	###############################################################

	echo "Initializing config file"
	> $CONFIG_FILE



	echo "Connection informations : "
	read -p "Host " SERVER
	read -p "Port " PORT
	read -p "Username " USERNAME
	read -p "Password " PASSWORD

	echo "Which database system do you use ?" 
	echo "- PostgreSQL (type postgres)" 
	echo "- MySQL (mysql)"
	read -p "? " DBMS_TYPE


	echo "Testing connection..." 

	case $DBMS_TYPE in 
		postgres)
			echo "DBMS_TYPE=postgres" >> $CONFIG_FILE
			PGUSER=$USERNAME
			PGHOST=$SERVER
			PGPORT=$PORT
			PGPASS=$PASSWORD
			$PSQL_EXE -h $SERVER -p $PORT -U $USERNAME -w -c "SELECT now();"
			RETOUR=$?
			if [ $RETOUR -ne 0 ]
				then 
				echo "Error at connecting to PostgreSQL server..."
				exit 1
			fi
		;;
		mysql)

			echo "Not yet implemented. Exiting..."
			exit 0
			echo "DBMS_TYPE=mysql" >> $CONFIG_FILE
		;;
		*)
			echo "Wrong DBMS type, exiting..."
			rm $CONFIG_FILE
			exit 1
		;;
	esac

fi