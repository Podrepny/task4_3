#!/bin/bash

LANG=C.UTF-8
DIR_BACKUP="/tmp/backups"
MAX_BACKUP=999
EXIT_CODE=0
DATE_CUR=`date +%Y-%m-%d-%H-%M-%S-%N`
OLD_PWD=`pwd`
DIRECTORY1=$1
OPTION2=$2
MAX_LENGTH_PATH=255

if [ "$#" -ne "2" ]; then
	echo -e "\nInvalid number of operand"
	EXIT_CODE=1
else
	if [ -n "$1" ] && [ ! -d "$1" ]; then
		echo -e "\nDIRECTORY do not exist: $1"
		EXIT_CODE=1
	fi
	if (echo "$2" | grep -E -q "^?[0-9]+$"); then
		if [ "$2" -lt "1" ] || [ "$2" -gt "$MAX_BACKUP" ]; then
			echo -e "\nOPTION is invalid: $2\nExpected from 1 to $MAX_BACKUP"
			EXIT_CODE=1
		fi
	else
		echo -e "\nOPTION is invalid: $2\nMust be a number from 1 to $MAX_BACKUP"
		EXIT_CODE=1
	fi
fi
# Show error
if [ "$EXIT_CODE" -eq 1 ]; then
	echo -e "\nUsage: $0 DIRECTORY... OPTION..."
	echo "       DIRECTORY - Absolute path to dir"
	echo "       OPTION - The number of backups to store in $DIR_BACKUP"
	echo "                value from 1 to $MAX_BACKUP"
	echo -e "\nEXAMPLE: $0 /home/ 2\n"
	exit 1
fi
# Compiling the file name
SOURCE_DIR=`echo $1 | sed 's/\/$//g'`
BACKUP_DIR_NAME=`echo $1 | sed 's/\/$//g' | sed 's/^\///g' | sed 's/\//-/g'`
BACKUP_FILENAME="$BACKUP_DIR_NAME-$DATE_CUR.tar.gz"
SEARCH_TEMPLATE="$BACKUP_DIR_NAME-[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}-[0-9]\{2\}-[0-9]\{2\}-[0-9]\{2\}-[0-9]\{9\}.tar.gz"
CUR_LENGTH_PATH=`echo "$DIR_BACKUP/$BACKUP_FILENAME" | wc -m`
if [ "$CUR_LENGTH_PATH" -gt "$MAX_LENGTH_PATH" ]; then
	echo -e "\nError: Path to long \n$CUR_LENGTH_PATH"
	exit 1
fi
# Create dir
if [ ! -d $DIR_BACKUP ]; then
	mkdir $DIR_BACKUP
fi
# Archiving
if [ -f "$DIR_BACKUP/$BACKUP_FILENAME" ]; then
	echo -e "Error: A backup file with the same name already exists\nBackup not created\n"
	exit 1
fi
tar -czf "$DIR_BACKUP/$BACKUP_FILENAME" "$SOURCE_DIR" 
if [ $? -ne "0" ]; then
	echo -e "\nError: During archiving\nBackup not created\n"
	exit 1
fi
# Backup count
PREV_BACKUP_PATH=`echo "$DIR_BACKUP/$BACKUP_DIR_NAME" | sed 's/\ /\\\ /g'`
PREV_BACKUP_LIST=`ls $DIR_BACKUP | grep "$SEARCH_TEMPLATE"`
PREV_BACKUP_COUNT=`ls -r $DIR_BACKUP | grep "$SEARCH_TEMPLATE" | wc -l` > /dev/null
# Delete unnecessary
PREV_BACKUP_TO_DEL=$((PREV_BACKUP_COUNT - OPTION2))
if [ "$PREV_BACKUP_TO_DEL" -gt "0" ]; then
	cd $DIR_BACKUP
	ls -r $DIR_BACKUP | grep "$SEARCH_TEMPLATE" | tail -n $PREV_BACKUP_TO_DEL | sed 's/\ /\\\ /g' | xargs rm
	# echo "Old backup deleted: $PREV_BACKUP_TO_DEL"
	cd $OLD_PWD
fi
exit 0
