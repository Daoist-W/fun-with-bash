#!/bin/bash

# Loops through each host provided as an argument and installs apache as well as enabling the web
# server process to start on boot. 

# Also creates an index.html file in the web server DocumentRoot that contains the servers hname


# setting up global variables
SSH_OPTIONS='-o ConnectTimeout=2'
EXIT_STATUS=0
LOGFILE='logfile'
VERBOSE='false'

# setting up utility functions
function usage {
	echo -e "Usage ${0} [-v] \e[4mHOST\e[0m [HOSTS]... " >&2
	echo '	Install apache on one or more hosts provided' >&2
	echo ' 	  -v    	Verbose mode' >&2
}

function checkStatus {
	EXIT_STATUS=${?}
	if [[ ${EXIT_STATUS} -ne 0 ]]; then
		#statements
		echo "ERROR: ($EXIT_STATUS) - ${@}" >&2
		sleep 1
	fi
	return $EXIT_STATUS
}

## function to show output when verbose
function catlog {
	if [[ ${VERBOSE} = 'true' ]]; then
		cat $LOGFILE
	fi
}


## Error log
function logerror {
	local ERROR="${@}"
	echo "${ERROR}" >&2
	exit 1
}


# intro
echo "Install Apache Tool v1.0"
echo
sleep 1

# check for root privilages
if [[ ${UID} -eq 0 ]]
then
	logerror "ERROR: Please execute *WITHOUT* root privilages"
fi


# parse options 
while getopts v OPTION
do
	case ${OPTION} in
		v)
			VERBOSE='true'
			;;
		?)
			usage
			logerror "ERROR: Invalid option"
			;;
	esac
done


# remove options and check for arguments 
shift $((OPTIND - 1))

if [[ ${#} -lt 1 ]]
then
	usage
	logerror "ERROR: Please supply at least one host to install Apache on"
fi


# loop through hosts provided
SERVERS=${@}

for SERVER in $SERVERS
do
	echo "---------------------------------------------------------------" &> $LOGFILE
	echo "Installing Apache on $SERVER ..." &>> $LOGFILE
	# pings host and if response not recieved, continues onto next host 
	ping -c 1 $SERVER &> /dev/null
	checkStatus "Host appears to be down, continuing on to next host..."
	if [[ ${?} -ne 0 ]]; then
		#statements
		continue 
	fi

	# install apache webserver
	ssh $SSH_OPTIONS $SERVER sudo yum install -y httpd &>> $LOGFILE
	checkStatus "Connection to $SERVER timed out when trying to install Apache"
	if [[ ${?} -ne 0 ]]; then
		#statements
		continue 
	fi	

	################################################################################
	# 									WARNING
	################################################################################
	# Be careful when sending commands through pipes and redirecting output IN GENERAL
	# sudo doesn't carry over these operators and so you need to use tee or other tools

	# place index.html file inside DocumentRoot
	ssh $SSH_OPTIONS $SERVER 'echo "${HOSTNAME}" Web Service is online | sudo tee /var/www/html/index.html' &>> $LOGFILE
	checkStatus "Error occured when creating default index.html for $SERVER"

	# enable web server 
	ssh $SSH_OPTIONS $SERVER sudo systemctl enable httpd &>> $LOGFILE
	checkStatus "Error occured when enabling $SERVER webserver"

	# start web server
	ssh $SSH_OPTIONS $SERVER sudo systemctl start httpd &>> $LOGFILE
	checkStatus "Error occured when starting $SERVER webserver"
	if [[ ${?} -ne 0 ]]; then
		#statements
		continue 
	fi		

	# using curl to test webserver is live 
	curl http://${SERVER} &>> $LOGFILE
	checkStatus "Error occured when testing $SERVER webserver is live"
	catlog

	if [[ ${EXIT_STATUS} -eq 0 ]]; then
		#statements
		echo "Installation for $SERVER complete "
		echo
	fi

done

echo "Finished installation process"

exit $EXIT_STATUS


