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
export CONFIG_FILE=dump.properties
export PSQL_EXE=psql
PGDUMP_EXE=pg_dump
export MYSQL_EXE=mysql
export PGDUMP_EXE
export DUMP_DIRECTORY=/home/spaulding/dumps

if [ ! -d $DUMP_DIRECTORY ]
	then 
	mkdir -p $DUMP_DIRECTORY
fi


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
	echo "Password "
	read -s PASSWORD

	echo "Which database system do you use ?" 
	echo "- PostgreSQL (type postgres)" 
	echo "- MySQL (mysql)"
	read -p "? " DBMS_TYPE 
fi

echo "Testing connection..."
case $DBMS_TYPE in 
	postgres)
		echo "DBMS_TYPE=postgres" >> $CONFIG_FILE
		export PGUSER=$USERNAME
		export PGHOST=$SERVER
		export PGPORT=$PORT
		export PGPASSWORD=$PASSWORD

		echo "USERNAME=$USERNAME" >> $CONFIG_FILE
		echo "SERVER=$SERVER" >> $CONFIG_FILE
		echo "PORT=$PORT" >> $CONFIG_FILE
		echo "PASSWORD=$PASSWORD" >> $CONFIG_FILE

		echo "Connecting to PostgreSQL with user : $PGUSER on server $PGHOST:$PGPORT"
		$PSQL_EXE -w -c "SELECT now();" > /dev/null 2>&1
		RETOUR=$?
		if [ $RETOUR -ne 0 ]
			then 
			echo "Error at connecting to PostgreSQL server..."
			exit 1
		fi

		echo "List of databases :"
		$PSQL_EXE -w -c "\l"

		if [ "$DATABASES_TO_DUMP" == "" ] 
		then
			read -p "Which databases to dump (separated by whitespaces) ? " DATABASES_TO_DUMP
			echo "DATABASES_TO_DUMP=$DATABASES_TO_DUMP" >> $CONFIG_FILE
		fi

		./dump_postgres_databases.sh $DATABASES_TO_DUMP
		
		
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


exit 0