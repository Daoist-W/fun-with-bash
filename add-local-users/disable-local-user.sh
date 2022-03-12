#!/bin/bash 

# This script will disable a specified account 
# By default, the account specified will be disabled
# User can specify a number of options should they wish to 

echo
echo "Disable/Delete Local User Tool"
echo
sleep 1

# Global variables
ARCHIVE_DIR='/archives/users'
DISABLE_USER='true'
DELETE_USER='false'
VERBOSE='false'
REMOVE_HOME_DIRECTORY='false'
ARCHIVE='false'

# Define functions here
## usage function
function usage {
	echo -e "Usage ${0} [-d] [-r] [-a] \e[4mUSERNAMES\e[0m [USERN]... " >&2
	echo 'Disable local Linux Account(s)'
	echo ' -d    Deletes accounts instead of disabling them.'
	echo ' -r    Removes home directory associated with accounts.'
	echo ' -a    Creates an archive of the home directory associated with the accounts.'
}

function checkStatus {
	if [[ ${?} -ne 0 ]]; then
		#statements
		logerror "${@}"
	fi
}

# checking to ensure system accounts aren't deleted
function check_id {
	local USER="${@}"
	local USERID=$(id -u ${USER})
	if [[ ${USERID} -lt 1001  ]]; then
		#statements
		logerror "ERROR: Cannot process system accounts (with User Id's less than 1000)"
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


## Deletion function with remove directory option
function deleteUser {
	local USER="${@}"
	check_id ${USER}

	if [[ ${DELETE_USER} == 'false' ]]; then
		#statement checks if delete needs to be ran
		return 1
	fi


	if [[ ${REMOVE_HOME_DIRECTORY} = 'true' ]]; then
		#statements
		userdel ${REMOVE_FLAG} ${USER} 2> /dev/null
		checkStatus "ERROR: Could not delete or remove ${USER} Account or Directory"
		log "Successfully deleted ${USER} Account and Home Directory"
	else
		userdel ${USER} 2> /dev/null
		checkStatus "ERROR: Could not delete or remove ${USER} Account"
		log "Successfully deleted ${USER}"
	fi
}

function archiveUser {
	local USER="${@}"
	check_id ${USER}
	if [[ ${ARCHIVE} = 'true' ]]; then
		#statements
		if [[ ! -d "${ARCHIVE_DIR}" ]]; then
			#statements
			log "Creating ${ARCHIVE_DIR} directory."
			mkdir -p ${ARCHIVE_DIR} 2> /dev/null
			checkStatus "ERROR: Could not create Directory ${ARCHIVE_DIR}"
		fi
		# Specify the destination and source directory to archive 
		HOME_DIR="/home/${USER}/"
		DESTINATION_DIR="${ARCHIVE_DIR}/${USER}-$(date +%y%m%d-%H%M%S).tar.gz"

		# check home directory exists
		if [[ ! -d "${HOME_DIR}" ]]; then
			#statements
			logerror "ERROR: Home directory does not exist or is not a directory."
		fi

		tar -czf ${DESTINATION_DIR} ${HOME_DIR}  2> /dev/null
		checkStatus "ERROR: Could not archive ${USER} Home Directory"
		log "Successfully archived ${USER} Home Directory to ${DESTINATION_DIR}"
	else
		return 1
	fi
}

function disableUser {
	local USER="${@}"
	if [[ ${DISABLE_USER} = 'true' ]]; then
		#statements
		chage -E 0 ${USER} 2> /dev/null
		checkStatus "ERROR: Could not disable User Account ${USER}"
		log "Successfully disabled User Account ${USER}"
	else
		return 1
	fi
}


# Function to loop through specified user list and invoke function passed as argument
function process_users {
	# iterates through specified usernames
	## if successful, displays with verbosity tasks completed
	local FUNC=${1}
	local ACTION=${2}
	shift 2
	local USERS=${@}
	for USER in ${USERS}
	do
		# expression
		${FUNC} ${USER}
	done
	if [[ ${?} -eq 0 ]]; then
		#statements
		echo
		log "${ACTION} completed!"
		echo
	fi
}


## Removal check
## Archive check
## UID check for specified accounts

# Checks for root privilages 
if [[ ${UID} -ne 0 ]]
then
	logerror "You do not have root privilages, please try again with sudo or as root user"
fi


# parse options 
while getopts drav OPTION 
do
	case ${OPTION} in
		v)
			#statement
			VERBOSE='true'
			log 'Verbose mode activated	'
		;;
		d)
			#statement
			DELETE_USER='true'
			DISABLE_USER='false'
			log "Deleting users..."
		;;
		r)
			#statement
			REMOVE_HOME_DIRECTORY='true'
			REMOVE_FLAG='-r'
			DELETE_USER='true'
			DISABLE_USER='false'
			log 'Removing Users and their Home Directories'
		;;
		a)
			#statement
			ARCHIVE='true'
			log 'Archiving User Home Directories'
		;;
		?)
			#statement
			usage
			exit 1
		;;
	esac
done

# remove options and retain only username arguments 
shift $(expr ${OPTIND} - 1)


# check that the user has supplied at least one options
if [[ ${#} -eq 0 ]]; then
	#statements
	usage 
	logerror "ERROR: You need to supply at least 1 Username"
fi

# loop through all users and apply modifications specified by options
echo
process_users archiveUser "Archiving" ${@}
process_users deleteUser "Deleting" ${@}
process_users disableUser "Disabling" ${@}


# General message saying all specified accounts deleted
echo 
echo "Done! Goodbye."
