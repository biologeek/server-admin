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



if [ -f $CONFIG_FILE ]
	then
	# Batch is already parametered. Sourcing config and starting dump
	. $CONFIG_FILE
fi

ARRAY=$(echo $IN | tr ";" "," " ")


for ELT in $ARRAY
do
	export PGDATABASE="$ELT"
	FILENAME="$ELT_`date +"%Y%m%d`_`date +"%HH.MM.ss`.dump"

	$PGDUMP_EXE -f $DUMP_DIRECTORY/$FILENAME 
done


exit 0