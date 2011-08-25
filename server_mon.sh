#!/bin/bash

#SUPERV_PROCS=("$@"
SUPERV_NUM_PROCS=$#
#want to create an additional log?
LOG_ENABLED=true
LOG_FILE_LOCATION=/home/aremind/www/production/log/pingdom_log.log
#folder where you'd like to host the pid file for this process monitor
PINGDOM_FILE_LOC=/home/aremind/www/production/code_root/static_files/pingdom
#file name of the PID file. Can be anything
PINGDOM_FILE_NAME=aremind_server_procs.pid
DEBUG=True

PROC_STATUS=OK
######################################
#Example check file contents. Must follow this structure!  Using the response time for number of processes:
#
#<pingdom_http_custom_check>
#        <status>OK</status>
#        <response_time>96.777</response_time>
#</pingdom_http_custom_check>
#
#######################################

if [ $DEBUG ]
then
	echo DEBUG IS ENABLED.
fi


for var in $@
do
	#the meat of the script.
	PROC_STATUS_TEXT=`/usr/bin/supervisorctl status | grep $var`
	PROC_RUNNING=`/usr/bin/supervisorctl status | grep $var | grep RUNNING`
	if [ -z "$PROC_RUNNING" ]
	then
		IS_RUNNING="False"
		PROC_STATUS=FAIL
	else
		IS_RUNNING="True"
	fi
	
	if [ $DEBUG ]
	then
		echo "--------------------------------"
		echo "For proc: $var::"
		echo `date`": $PROC_STATUS_TEXT"
		echo "IS PROC RUNNING?: $IS_RUNNING"
		echo "PROC_RUNNING: $PROC_RUNNING"
		echo "--------------------------------"
		echo 
		echo
	fi
		
	if [ $LOG_ENABLED ]
	then
		echo `date`": $PROC_STATUS_TEXT" >> $LOG_FILE_LOCATION
		if [ $PROC_STATUS == "FAIL" ]
		then
			echo `date`": PROCESS $var IS DOWN"
		fi
	fi
done

echo "<pingdom_http_custom_check><status>$PROC_STATUS</status><response_time>$#</response_time></pingdom_http_custom_check>" > $PINGDOM_FILE_LOC/$PINGDOM_FILE_NAME

if [ $DEBUG ]
then
	echo "outputting PINGDOM FILE:"
	echo "---------------------STARTFILE:"
	cat $PINGDOM_FILE_LOC/$PINGDOM_FILE_NAME
	echo ":ENDFILE------------------------"
fi

