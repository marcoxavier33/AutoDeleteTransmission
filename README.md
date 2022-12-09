# AutoDeleteTransmission

You are aware that when you delete a file from Sonarr/Radarr, it do not delete it in the transmission folder, which can cause disk space problems.
Sonarr and Radarr only delete the torrent when it has finished seeding. If you're like me and like to leave your torrents in permanent seed until you delete it, this script might be able to help you.

The goal is simple, the script must be run regularly via the crontab, it will look if files have been deleted in the Sonarr / Radarr folders (when you delete it in the web interface, and checked the box)by comparing with the files you have in your transmission download folder. If it notices a difference then it will go and delete the torrent on transmission via the API.

To make it work you will still need to make some changes, here is the list of important things to change:

YOU'LL NEED TO INSTALL JQ

Line 2 & 3: 
RADARR_PATH and SONARR_PATH = your radarr and sonarr path when imported
BASE_DIRECTORY = your transmission path downloads

Line 30:
API_URL = your transmission ip:port 

And here are the optional variables :

Line 27:
SEND_NOTIFICATION = "yes" to send a notification on your "Pushover" app and "no" to stop it. 

Line 72 & 73:
APP_TOKEN = your tokens. You'll need to download the app to get the User token and create an application token on their website
USER_TOKEN = same as APP_TOKEN

Line 28:
AUTO_DELETE = if at "yes" it will delete your torrent in transmission if file missing in sonarr/radarr directory and if "no" it will return you the name & the ID of the torrent it will delete if you turn it at "yes"

Line 29 & 72:
BEFORE_CLEAN = you should add the right path to check the space on your server
AFTER_CLEAN = same as BEFORE_CLEAN

This script is largely optimizable, I share it with you in the current state since it works. I will probably make updates in the future.
It is also possible I think to adapt it for other download clients.
