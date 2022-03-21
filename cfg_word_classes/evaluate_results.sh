#!/bin/bash

for i in $(cat recognizer_log.txt | grep res | sed -e 's/.*res\: //'); do
	echo $i;
#	echo $(echo $i | sed -e 's/<EPS>//g')
	if (echo $i | grep -q "<WDAY>"); then
		WEEKDAY=$(echo $i | sed -e 's/<EPS>//g' | sed -r 's/.*<WDAY>(.*)<\/WDAY>.*/\1/')
	else
		WEEKDAY=NONE
	fi
	if (echo $i | grep -q "<TIME>"); then
		TIME=$(echo $i | sed -e 's/<EPS>//g' | sed -r 's/.*<TIME>(.*)<\/TIME>.*/\1/')
	else
		TIME=NONE
	fi
	if (echo $i | grep -q "<DATE>"); then
		DATE=$(echo $i | sed -e 's/<EPS>//g' | sed -r 's/.*<DATE>(.*)<\/DATE>.*/\1/')
	else
		DATE=NONE
	fi
	echo "Weekday=$WEEKDAY, Date=$DATE, Time=$TIME"

	if [ "$WEEKDAY" != "NONE" ]; then
		WEEKDAYNAME=$(date +"%A" -d "Sunday $WEEKDAY day")
	else
		WEEKDAYNAME="no_weekday"
	fi
	
	if [ "$DATE" != "NONE" ]; then
		DATENAME=$(date +"%d.%m." -d "Dec 31 2022 $(($DATE)) days")
	else
		DATENAME="no_date"
	fi
	
	if [ "$TIME" != "NONE" ]; then
		TIMENAME=$(date +"%H:%M" -d "Jan 1 2022 $(($TIME)) minutes")" Uhr"
	else
		TIMENAME="no_time"
	fi
	
	echo "$WEEKDAYNAME - $DATENAME - $TIMENAME"
	
	echo "========================================"
done
