#!/bin/bash
source vars/vars.ini
START_TIME=$(date +%s)
readarray -d '' files1 < <(find $RADARR_PATH -type f -print0 | sort -z; find $SONARR_PATH -type f -print0 | sort -z)
readarray -d '' files2 < <(find $BASE_DIRECTORY -name *.mkv ! -name '*sample*' -type f -print0 | sort -z)

for ((i=0; i<${#files2[@]}; i++))
do
	for ((j=0; j<${#files1[@]}; j++))
	do
		diff -s "${files2[$i]}" "${files1[$j]}" > /dev/null
		if [[ $? == 0 ]]; then
			present="yes"
			break
		else
			present="no"
		fi
	done
	if [[ $present == "no" ]]; then
		if [[ -n ${files2[$i]} ]];then
			result+=("${files2[$i]}")
		fi
	fi
done

BEFORE_CLEAN=$(df -h $BASE_DIRECTORY | awk '{print $4 " " $5}' | sed '1d')
SESSION_ID=$(curl -s $API_URL | grep -oP '(?<=X-Transmission-Session-Id: )[^<]+')
for ((u=0; u<${#result[@]}; u++))
do
	FILE=("${result[$u]}")
	FILE=$(basename "$FILE")
	FIND_FILE=$(find $BASE_DIRECTORY -type f -name "$FILE")
	FOLDER_DEPTH_1="$(basename "$(dirname "$(dirname "$FIND_FILE")")")"
	FOLDER_DEPTH_MAX="$(basename "$(dirname "$FIND_FILE")")"
	if [[ -f $BASE_DIRECTORY/$FILE ]]; then
		source functions/functions.sh
		delete_torrent "$FILE"
	elif [[ -f $BASE_DIRECTORY/$FOLDER_DEPTH_MAX/$FILE ]]; then
		FILE="$FOLDER_DEPTH_MAX"
		source functions/functions.sh
		delete_torrent "$FILE"
	elif [[ -f $BASE_DIRECTORY/$FOLDER_DEPTH_1/$FOLDER_DEPTH_MAX/$FILE ]]; then
		FILE="$FOLDER_DEPTH_1"
		source functions/functions.sh
		delete_torrent "$FILE"
	else
		echo "File not found in transmission or already deleted"
	fi
done

END_TIME=$(date +%s)
ELAPSED_TIME=$((END_TIME-START_TIME))
hours=$((ELAPSED_TIME / 3600))
minutes=$((ELAPSED_TIME % 3600 / 60))
seconds=$((ELAPSED_TIME % 60))
EXEC_TIME=$(printf "Temps d'exécution : %02d:%02d:%02d\n" $hours $minutes $seconds)
AFTER_CLEAN=$(df -h $BASE_DIRECTORY | awk '{print $4 " " $5}' | sed '1d')
MESSAGE="Disk space before clean : $BEFORE_CLEAN<br>Disk space after clean : $AFTER_CLEAN<br>$EXEC_TIME"
if [[ $SEND_NOTIFICATION == "yes" ]]; then
	if [[ "$BEFORE_CLEAN" != "$AFTER_CLEAN" ]]; then
		curl -s --form-string "token=$APP_TOKEN" --form-string "user=$USER_TOKEN" --form-string "message=$MESSAGE" --form-string "html=1" https://api.pushover.net/1/messages.json > /dev/null
	else
		curl -s --form-string "token=$APP_TOKEN" --form-string "user=$USER_TOKEN" --form-string "message=$EXEC_TIME" --form-string "html=1" https://api.pushover.net/1/messages.json > /dev/null
	fi
fi

