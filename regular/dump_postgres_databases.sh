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


SUCCESSFUL_DUMPS=0

if [ -f $CONFIG_FILE ]
	then
	# Batch is already parametered. Sourcing config and starting dump
	. $CONFIG_FILE
fi

for ELT in $@
do
	
	export PGDATABASE="$ELT"
	FILENAME="$ELT.`date +"%Y%m%d"`.`date +"%H%M%s"`.dump"
	
	echo "Dumping $ELT in file $DUMP_DIRECTORY/$FILENAME..."
	$PGDUMP_EXE --inserts > $DUMP_DIRECTORY/$FILENAME 
	RETOUR=$?
	
	if [ $RETOUR -ne 0 ]
	then
		echo "*** ERROR at dumping $ELT"
		echo "Continuing to next DB..."
	else
		echo "Successful dumping !!"
		SUCCESSFUL_DUMPS=`expr $SUCCESSFUL_DUMPS + 1`
	fi
done


echo "$SUCCESSFUL_DUMPS / $# successful dumps !!"

exit 0