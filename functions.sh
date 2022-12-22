#!/bin/bash
source vars.ini
delete_torrent () {
	PERCENT_DONE=$(curl --silent -H "X-Transmission-Session-Id: $SESSION_ID" $API_URL -d '{"method":"torrent-get","arguments":{"fields":["name","id","percentDone"]}}' | jq -r '.arguments.torrents[] | select(.name=="'"$1"'") | .percentDone')
	if [[ $PERCENT_DONE -eq 1 ]]; then
		ID_TORRENT=$(curl --silent -H "X-Transmission-Session-Id: $SESSION_ID" $API_URL -d '{"method":"torrent-get","arguments":{"fields":["name","id"]}}' | jq -r '.arguments.torrents[] | select(.name=="'"$1"'") | .id')
		if [[ $AUTO_DELETE == "yes" ]]; then
			PAYLOAD=$(echo "{\"method\":\"torrent-remove\",\"arguments\":{\"ids\":[$ID_TORRENT],\"delete-local-data\":true}}" | jq -c)
			curl -X POST $API_URL -H "X-Transmission-Session-Id: $SESSION_ID" -d $PAYLOAD > /dev/null
		elif [[ $AUTO_DELETE == "no" ]]; then
			echo "$1"
			echo "$ID_TORRENT"
		fi
	fi
}
