#!/bin/bash
RADARR_PATH="path"
SONARR_PATH="path"
BASE_DIRECTORY="path to transmission downloads folder"
readarray -d '' files1 < <(find $RADARR_PATH -type f -print0; find $SONARR_PATH -type f -print0)
readarray -d '' files2 < <(find $BASE_DIRECTORY -name *.mkv ! -name '*sample*' -type f -print0)

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

SEND_NOTIFICATION="no"
AUTO_DELETE="no"
BEFORE_CLEAN=$(df -h | grep /DATA | awk '{print $4 " " $5}')
API_URL="http://ip:port/transmission/rpc/"
SESSION_ID=$(curl -s $API_URL | grep -oP '(?<=X-Transmission-Session-Id: )[^<]+')
for ((u=0; u<${#result[@]}; u++))
do
	FILE=("${result[$u]}")
	FILE=$(basename "$FILE")
	FIND_FILE=$(find $BASE_DIRECTORY -type f -name "$FILE")
	FOLDER_DEPTH_1="$(basename "$(dirname "$(dirname "$FIND_FILE")")")"
	FOLDER_DEPTH_MAX="$(basename "$(dirname "$FIND_FILE")")"
	if [[ -f $BASE_DIRECTORY/$FILE ]]; then
		ID_TORRENT=$(curl --silent -H "X-Transmission-Session-Id: $SESSION_ID" $API_URL -d '{"method":"torrent-get","arguments":{"fields":["name","id"]}}' | jq -r '.arguments.torrents[] | select(.name=="'"$FILE"'") | .id')
		if [[ $AUTO_DELETE == "yes" ]]; then
			PAYLOAD=$(echo "{\"method\":\"torrent-remove\",\"arguments\":{\"ids\":[$ID_TORRENT],\"delete-local-data\":true}}" | jq -c)			
			curl -X POST $API_URL -H "X-Transmission-Session-Id: $SESSION_ID" -d $PAYLOAD > /dev/null
		elif [[ $AUTO_DELETE == "no" ]]; then
			echo "$FILE"
			echo "$ID_TORRENT"
		fi
	elif [[ -f $BASE_DIRECTORY/$FOLDER_DEPTH_MAX/$FILE ]]; then
		FILE="$FOLDER_DEPTH_MAX"
		ID_TORRENT=$(curl --silent -H "X-Transmission-Session-Id: $SESSION_ID" $API_URL -d '{"method":"torrent-get","arguments":{"fields":["name","id"]}}' | jq -r '.arguments.torrents[] | select(.name=="'"$FILE"'") | .id')
		if [[ $AUTO_DELETE == "yes" ]]; then
			PAYLOAD=$(echo "{\"method\":\"torrent-remove\",\"arguments\":{\"ids\":[$ID_TORRENT],\"delete-local-data\":true}}" | jq -c)
			curl -X POST $API_URL -H "X-Transmission-Session-Id: $SESSION_ID" -d $PAYLOAD > /dev/null
		elif [[ $AUTO_DELETE == "no" ]]; then
			echo "$FILE"
			echo "$ID_TORRENT"
		fi
	elif [[ -f $BASE_DIRECTORY/$FOLDER_DEPTH_1/$FOLDER_DEPTH_MAX/$FILE ]]; then
		FILE="$FOLDER_DEPTH_1"
		ID_TORRENT=$(curl --silent -H "X-Transmission-Session-Id: $SESSION_ID" $API_URL -d '{"method":"torrent-get","arguments":{"fields":["name","id"]}}' | jq -r '.arguments.torrents[] | select(.name=="'"$FILE"'") | .id')
		if [[ $AUTO_DELETE == "yes" ]]; then
			PAYLOAD=$(echo "{\"method\":\"torrent-remove\",\"arguments\":{\"ids\":[$ID_TORRENT],\"delete-local-data\":true}}" | jq -c)
			curl -X POST $API_URL -H "X-Transmission-Session-Id: $SESSION_ID" -d $PAYLOAD > /dev/null
		elif [[ $AUTO_DELETE == "no" ]]; then
			echo "$FILE"
			echo "$ID_TORRENT"
		fi
	else
		echo "File not found in transmission or already deleted"
	fi
done
AFTER_CLEAN=$(df -h | grep /DATA | awk '{print $4 " " $5}')
APP_TOKEN="APP TOKEN"
USER_TOKEN="USER TOKEN"
if [[ $SEND_NOTIFICATION == "yes" ]]; then
	curl -s --form-string "token=$APP_TOKEN" --form-string "user=$USER_TOKEN" --form-string "message=Disk space before clean : $BEFORE_CLEAN<br>Disk space after clean : $AFTER_CLEAN" --form-string "html=1" https://api.pushover.net/1/messages.json > /dev/null
fi
