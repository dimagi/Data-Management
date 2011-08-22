#!/bin/bash

#This is the process string line.  Run 'sudo supervisorctl status' to see some other examples.
SUPERV_PROC_NAME='aremind-production:aremind-production-celerybeat'
HERE=./
#folder where you'd like to host the pid file for this process monitor
PINGDOM_FILE_LOC=/home/aremind/www/production/code_root/static_files/pingdom
#file name of the PID file. Can be anything
PINGDOM_FILE_NAME=aremind_celerybeat.pid

#want to create an additional log?
LOG_ENABLED=true
LOG_FILE_LOCATION=/home/aremind/www/production/log/pingdom_log.log

#the meat of the script.
PROC_STATUS=`/usr/bin/supervisorctl status | grep $SUPERV_PROC_NAME`
PROC_RUNNING=`/usr/bin/supervisorctl status | grep $SUPERV_PROC_NAME | grep RUNNING`

if [ $LOG_ENABLED ]
then
	echo "`date` LOGGING TO LOG: $PROC_STATUS"
	echo "PROCESS UP: $PROC_STATUS" >> $LOG_FILE_LOCATION
fi

if [ ! -z "$PROC_RUNNING" ]
then
	touch $PINGDOM_FILE_LOC/$PINGDOM_FILE_NAME
else
	rm $PINGDOM_FILE_LOC/$PINGDOM_FILE_NAME
fi

