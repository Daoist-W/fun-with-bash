#!/bin/bash

# Welcome 
echo
echo "Add Local User Tool v1.3"
sleep 2
echo

# Check for root user privilages, using STDERR for feedback upon failure 
if [[ ${UID} -ne 0 ]]
then
	echo >&2
	echo "Error: Invalid user privilages, please execute with sudo privilages" >&2
	echo >&2
	echo "	add-local-user.sh - create a new user account (requires root privilages)" >&2
	echo >&2
	echo -e "	sudo add-local-user.sh \e[4mUSERNAME\e[0m [COMMENTS]" >&2
	echo "		USERNAME must be between 1-8 characters" >&2
	echo "		COMMENTS are optional" >&2
	echo "Exiting ..."
	sleep 1
	exit 1
	# All of the above to be displayed in STDERR
fi 


# validate username 
USER_NAME=${1}
if [ ${#USER_NAME} -lt 1 ] || [ ${#USER_NAME} -gt 8 ]
then
	echo >&2
	echo "Error: Invalid username" >&2
	echo >&2
	echo -e "	sudo add-local-user.sh \e[4mUSERNAME\e[0m [COMMENTS]" >&2
	echo "		USERNAME must be between 1-8 characters" >&2
	echo "		COMMENTS are optional" >&2
	echo "Exiting ..."
	sleep 1
	exit 1
fi

# store any remaining arguments in a single string for comments 
shift # consume argument at position 1
COMMENTS="${@}"

# User feedback 
echo "Please confirm account details:"
echo 
echo "Username: ${USER_NAME}"
echo "Comments: ${COMMENTS}"
echo

# this is a verification segment disabled for testing
# read -p "Details are correct? (y/n)" CONTINUE 
# echo

# if [[ ${CONTINUE} != "y" ]]
# then
# 	echo "Exiting ..."
# 	sleep 1
# 	exit 1
# fi

# Create user account 
echo "Attempting to create User Account..."
sleep 2
echo 

useradd -c "${COMMENTS}" -m ${USER_NAME} &> /dev/null

if [[ ${?} -ne 0 ]]
then
	echo "Error: something went wrong with the user creation process." >&2
	echo "Please try again or contact the technical department" >&2
	echo "Exiting ..." >&2
	sleep 1
	exit 1
fi 


# generate password, set it and then set to expire upon first login 
SPECIAL_CHAR1=$(echo '!@#$%^&*()_-+=' | fold -w1 | shuf | head -n1 )
SPECIAL_CHAR2=$(echo '!@#$%^&*()_-+=' | fold -w1 | shuf | head -n1 )
HASH=$(date +%s%N | sha256sum | head -c32)
PASSWORD=$(echo "${SPECIAL_CHAR1}${SPECIAL_CHAR2}${HASH}" | fold -w1 | shuf | tr -d "\n" )

# assign password to user account and then set it to expire at first login 
echo ${PASSWORD} | passwd -e --stdin ${USER_NAME} &> /dev/null 

if [[ ${?} -ne 0 ]]
then
	echo "Error: Something went wrong with the password generation" >&2
	echo "Please contact the technical department" >&2
	echo "Exiting ..." >&2
	sleep 1
	exit 1
fi 


# Notify User of account creation and display details 
echo "Account creation successful! Please review details below"
echo
echo "Host       : ${HOSTNAME}"
echo "Username   : ${USER_NAME}"
echo "Comment(s) : ${COMMENTS}"
echo "Password   : ${PASSWORD}"
echo
echo "NOTE: The password generated is temporary and the user MUST change this password on their first login"
echo 
sleep 1
echo "Goodbye!"

# delete demo account to prevent clogging up vm
# userdel -r ${USER_NAME}

