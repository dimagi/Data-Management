#!/bin/bash

SUPERV_PROCS=("$@")
SUPERV_NUM_PROCS=$#
#want to create an additional log?
LOG_ENABLED=true
LOG_FILE_LOCATION=/home/aremind/www/production/log/pingdom_log.log
#folder where you'd like to host the pid file for this process monitor
PINGDOM_FILE_LOC=/home/aremind/www/production/code_root/static_files/pingdom
#file name of the PID file. Can be anything
PINGDOM_FILE_NAME=aremind_celerybeat.pid
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

for var in $@
do
	#the meat of the script.
	PROC_STATUS_TEXT=`/usr/bin/supervisorctl status | grep $var`
	PROC_RUNNING=`/usr/bin/supervisorctl status | grep $var | grep RUNNING`
	if [ ! -z "$PROC_RUNNING" ]
	then
		IS_RUNNING = "False"
	else
		IS_RUNNING = "True"
	fi
	
	if [ $DEBUG ]
	do
		echo "--------------------------------"
		echo "For proc: $var::"
		echo "`date`: $PROC_STATUS_TEXT" 	
		echo "IS PROC RUNNING?: $IS_RUNNING"
		echo "--------------------------------"
	fi
		
	if [ $LOG_ENABLED ]
	then
		echo "`date`: $PROC_STATUS_TEXT" >> $LOG_FILE_LOCATION
	fi
	if [ ! -z "$PROC_RUNNING" ]
	then
		PROC_STATUS=FAIL
	fi
done

echo "<pingdom_http_custom_check><status>" > $PINGDOM_FILE_LOC/$PINGDOM_FILE_NAME
echo "$PROC_STATUS</status><response_time>96.777</response_time></pingdom_http_custom_check>" >> $PINGDOM_FILE_LOC/$PINGDOM_FILE_NAME

if [ $DEBUG ]
then
	echo "outputting PINGDOM FILE:"
	echo "---------------------STARTFILE:"
	cat $PINGDOM_FILE_LOC/$PINGDOM_FILE_NAME
	echo ":ENDFILE------------------------"
fi

