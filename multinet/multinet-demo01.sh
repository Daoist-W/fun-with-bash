#!/bin/bash

# This script pings a list of servers and reports their status.

SERVER_FILE=${1}

# check file exists
if [[ ! -e "${SERVER_FILE}" ]]
then
	echo "Cannot open file ${SERVER_FILE}" >&2
	exit 1
fi


for SERVER in $(cat ${SERVER_FILE})
do
    ping -c 1 ${SERVER} &> /dev/null
    if [[ ${?} -eq 0 ]]
    then
        echo ${SERVER} operational
    else
        echo ${SERVER} not responding
    fi
done
 
