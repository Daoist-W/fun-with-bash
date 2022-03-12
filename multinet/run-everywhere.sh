#!/bin/bash

# This script executes all arguments as a single command on every server listed in the /vagrant/servers
# by default the commands privided will be run as the user executing the script 

# by default, server list will be provided from /vagrant/servers
FILE_PATH='/vagrant/servers'
SSH_OPTIONS='-o ConnectTimeout=2'
EXIT_STATUS=0

# setting up utility functions
function usage {
	echo -e "Usage ${0} [-v] [-f] \e[4mFILEPATH\e[0m [-n] [-s] '\e[4mCOMMAND\e[0m' ['COMMANDS']... " >&2
	echo '	Execute all arguments as a single command on every server listed in file' >&2
	echo "	For commands with multiple options/inputs of their own, surround with" "'single'" 'or "double" quotes' >&2
	echo "	By default, the file containing the server list is ${FILE_PATH}" >&2
	echo -e ' 	  -f \e[4mFILEPATH\e[0m   Override default file path containing list of servers' >&2
	echo ' 	  -n    	Execute all commands in a Dry Run' >&2
	echo ' 	  -s    	Run all commands as root user of each server' >&2
	echo ' 	  -v    	Verbose mode' >&2
}

function checkStatus {
	EXIT_STATUS=${?}
	if [[ ${EXIT_STATUS} -ne 0 ]]; then
		#statements
		echo "Exit status: $EXIT_STATUS - ${@}" >&2
	fi
}

## Logging function
function log {
	local MESSAGE="${@}"
	if [[ ${VERBOSE} = 'true' ]]
	then
		echo "${MESSAGE}"
	fi
}

## Error log
function logerror {
	local ERROR="${@}"
	echo "${ERROR}" >&2
	exit 1
}


# Check for root privilages
if [[ ${UID} -eq 0 ]]
then
	logerror "ERROR: Do not execute this script as root. Use the -s option instead"
fi


# loop through options specified by user
while getopts f:nsv OPTION &> /dev/null
do
    case ${OPTION} in 
	f)
	    #statement
	    if [[ ! -e ${OPTARG} ]]
	    then
	    	logerror "File ${OPTARG} cannot be opened"
	    fi

	    FILE_PATH="${OPTARG}"
	    ;;
	n)
	    #statement
	    log "Activating Dry Run..."
	    DRY_RUN='true'
	    ;;
	s)
	    #statement
	    log "Setting user privilages to root for all commands..."
	    SUDO='sudo'
	    ;;
	v)
	    #statement
	    VERBOSE='true'
	    ;;
	?)
	    #handle invalid options
	    usage
	    logerror "ERROR: please specify a valid option, or make sure option arguments provided"
	    ;;
    esac
done

# Remove optional arguments and check that command has been submitted 
shift $(( OPTIND - 1))
if [[ ${#} -eq 0 ]]
then
	usage
	logerror "No commands supplied, please supply at least one command"
fi


# loops through servers listed in servers file 
while [[ ${#} -gt 0 ]]
do
	for SERVER in $(cat ${FILE_PATH})
	do
		SSH_COMMAND="ssh $SSH_OPTIONS $SERVER $SUDO ${1} 2> /dev/null"
	    # For each server, loop through command arguments
	    # if DRY_RUN is true, simply display commands to stdout
    	if [[ $DRY_RUN == 'true' ]]
    	then
    		echo "DRY RUN: $SSH_COMMAND"
    	else
    		log "$SERVER '$SUDO ${1}'"
	    	$SSH_COMMAND 2> /dev/null
	    	checkStatus "${1} failed to execute"
	    fi
	done
	# once all servers have executed this command, then shift to remove it
	shift
done

log 'Goodbye!'
exit $EXIT_STATUS


