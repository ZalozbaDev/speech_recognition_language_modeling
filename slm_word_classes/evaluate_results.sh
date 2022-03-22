#!/bin/bash

for i in $(cat recognizer_log.txt | grep res | sed -e 's/.*res\: //'); do
	echo $i;
#	echo $(echo $i | sed -e 's/<EPS>//g')
	if (echo $i | grep -q "<PERCENT>"); then
		PERCENT=$(echo $i | sed -e 's/<EPS>//g' | sed -r 's/.*<PERCENT>(.*)<\/PERCENT>.*/\1/')
	else
		PERCENT=NONE
	fi
	echo "Percent=$PERCENT"

	if [ "$PERCENT" != "NONE" ]; then
		PERCENTNAME=$(echo "$(($PERCENT))")"%"
	else
		PERCENTNAME="no_value"
	fi
	
	echo "Value=${PERCENTNAME}"
	
	echo "========================================"
done
